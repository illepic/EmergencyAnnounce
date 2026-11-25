-- EmergencyAnnounce: whisper the person and tell your group when an emergency
-- spell actually lands. On by default: Blessing of Protection, Blessing of
-- Freedom and Divine Intervention. Off by default: Lay on Hands and Blessing
-- of Sacrifice. Only successful casts are announced, so mashing the
-- key, being out of range or on cooldown never sends anything.
--
-- Copyright (C) 2026 Garreth Stonecrash
-- Licensed under the GNU General Public License v3.0 or later. See LICENSE.

local ADDON = ...

-- Every rank's spell ID. Names are read from the game at login, so any client
-- language works and a rank missing from this list still matches by name.
local SPELLS = {
    { key = "bop",       ids = { 1022, 5599, 10278 }, on = true  }, -- Blessing of Protection
    { key = "freedom",   ids = { 1044 },              on = true  }, -- Blessing of Freedom
    { key = "di",        ids = { 19752 },             on = true  }, -- Divine Intervention
    { key = "loh",       ids = { 633, 2800, 10310 },  on = false }, -- Lay on Hands: a big heal, but the target has nothing to react to
    { key = "sacrifice", ids = { 6940, 20729 },       on = false }, -- Blessing of Sacrifice
}

local DEFAULTS = {
    whisper = true,                       -- whisper the person you cast it on (never yourself)
    group = true,                         -- announce in party / raid / instance chat
    throttle = 10,                        -- seconds before the same spell on the same person repeats
    whisperText = "{spell} on you!",
    groupText = "{spell} on {target}",
    spells = {},
}
for _, s in ipairs(SPELLS) do DEFAULTS.spells[s.key] = s.on end

local db
local byID, byName = {}, {}
local pending
local last = {}

local function readable(v)
    return not issecretvalue or not issecretvalue(v)
end

local function spellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    return (GetSpellInfo(id))
end

local function say(msg)
    print("|cffffd200EmergencyAnnounce:|r " .. msg)
end

local function fill(text, vars)
    return (text:gsub("{(%a+)}", function(k) return vars[k] end))
end

local function copyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            copyDefaults(v, dst[k])
        elseif dst[k] == nil or type(dst[k]) ~= type(v) then
            dst[k] = v
        end
    end
end

local function buildLookup()
    for _, s in ipairs(SPELLS) do
        for _, id in ipairs(s.ids) do
            byID[id] = s
            local name = spellName(id)
            if name then byName[name] = s; s.name = s.name or name end
        end
    end
end

local function spellFor(id)
    local s = byID[id]
    local name = spellName(id)
    if not s and name then s = byName[name] end
    if s then return s, name or s.name end
end

-- The unit for a name we can see (group, target, mouseover, focus), so an NPC
-- never gets whispered and cross-realm players get their full name.
local function findUnit(name)
    local units = { "target", "mouseover", "targettarget", "focus" }
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do units[#units + 1] = "raid" .. i end
    else
        for i = 1, GetNumSubgroupMembers() do units[#units + 1] = "party" .. i end
    end
    for _, unit in ipairs(units) do
        local ok, short = pcall(UnitName, unit)
        local okFull, full = pcall(GetUnitName, unit, true)
        if ok and readable(short) and (short == name or (okFull and readable(full) and full == name)) then
            if UnitIsPlayer(unit) then return unit end
        end
    end
end

local function send(msg, channel, who)
    if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if not ok or not readable(locked) or locked then return false end
    end
    local fn = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    return (pcall(fn, msg, channel, nil, who))
end

local function groupChannel()
    if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
        and not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "INSTANCE_CHAT"
    end
    if IsInRaid() then return "RAID" end
    if IsInGroup() then return "PARTY" end
end

local function announce(spell, target)
    local key = spell .. "|" .. target
    local now = GetTime()
    if last[key] and now - last[key] < db.throttle then return end
    last[key] = now

    local me = UnitName("player")
    local isMe = target == me
    local ok = true
    if db.whisper and not isMe then
        local unit = findUnit(target)
        if unit then
            local who = GetUnitName(unit, true) or target
            ok = send(fill(db.whisperText, { spell = spell, target = target }), "WHISPER", who) and ok
        end
    end
    local channel = db.group and groupChannel()
    if channel then
        ok = send(fill(db.groupText, { spell = spell, target = isMe and "myself" or target }), channel) and ok
    end
    if not ok then
        say("chat was blocked, so " .. spell .. " on " .. target .. " wasn't announced.")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
frame:SetScript("OnEvent", function(_, event, a, b, c, d)
    if event == "ADDON_LOADED" then
        if a ~= ADDON then return end
        EmergencyAnnounceDB = EmergencyAnnounceDB or {}
        db = EmergencyAnnounceDB
        copyDefaults(DEFAULTS, db)
    elseif event == "PLAYER_LOGIN" then
        buildLookup()
    elseif event == "UNIT_SPELLCAST_SENT" then
        local target, castGUID, spellID = b, c, d
        if not db or not (readable(target) and readable(castGUID) and readable(spellID)) then return end
        local s, name = spellFor(spellID)
        if not s or not db.spells[s.key] then return end
        if not target or target == "" then target = UnitName("player") end
        pending = { guid = castGUID, spell = name, target = target, at = GetTime() }
    else -- UNIT_SPELLCAST_SUCCEEDED
        local castGUID = b
        if not readable(castGUID) or not pending or pending.guid ~= castGUID then return end
        local p = pending
        pending = nil
        if GetTime() - p.at < 5 then announce(p.spell, p.target) end
    end
end)

-- /ea --------------------------------------------------------------------

local function onOff(v) return v and "|cff40ff40on|r" or "|cffff4040off|r" end

local function spellLabel(s) return s.name or spellName(s.ids[1]) or s.key end

local function status()
    say("whisper " .. onOff(db.whisper) .. ", group " .. onOff(db.group)
        .. ", repeat after " .. db.throttle .. "s")
    say("whisper text: " .. db.whisperText)
    say("group text: " .. db.groupText)
    for _, s in ipairs(SPELLS) do
        print(("   %s (%s): %s"):format(spellLabel(s), s.key, onOff(db.spells[s.key])))
    end
    say("type |cffffffff/ea help|r for commands.")
end

local function help()
    say("commands:")
    print("   /ea - show your settings")
    print("   /ea whisper [on|off] - whisper the person you protect")
    print("   /ea group [on|off] - tell your party or raid")
    print("   /ea spell <key> [on|off] - choose spells (keys: bop, freedom, di, loh, sacrifice)")
    print("   /ea throttle <seconds> - wait before repeating for the same spell and person")
    print("   /ea whispertext <text> - {spell} and {target} are filled in")
    print("   /ea grouptext <text>")
    print("   /ea test - preview the messages in your chat only")
    print("   /ea reset - back to the defaults")
end

local function toggle(current, word)
    if word == "on" then return true elseif word == "off" then return false end
    return not current
end

SLASH_EMERGENCYANNOUNCE1 = "/ea"
SLASH_EMERGENCYANNOUNCE2 = "/emergencyannounce"
SlashCmdList.EMERGENCYANNOUNCE = function(input)
    if not db then return end
    local cmd, rest = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd:lower()
    local word = rest:lower()

    if cmd == "" or cmd == "status" then
        status()
    elseif cmd == "help" then
        help()
    elseif cmd == "whisper" or cmd == "group" then
        db[cmd] = toggle(db[cmd], word)
        say(cmd .. " " .. onOff(db[cmd]))
    elseif cmd == "spell" then
        local key, w = word:match("^(%S+)%s*(%S*)$")
        local found
        for _, s in ipairs(SPELLS) do if s.key == key then found = s end end
        if not found then say("unknown spell. Keys: bop, freedom, di, loh, sacrifice."); return end
        db.spells[found.key] = toggle(db.spells[found.key], w)
        say(spellLabel(found) .. " " .. onOff(db.spells[found.key]))
    elseif cmd == "throttle" then
        local n = tonumber(word)
        if not n or n < 0 or n > 300 then say("give a number of seconds from 0 to 300."); return end
        db.throttle = n
        say("repeat after " .. n .. "s")
    elseif cmd == "whispertext" or cmd == "grouptext" then
        local field = cmd == "whispertext" and "whisperText" or "groupText"
        if rest == "" then say(cmd .. ": " .. db[field]); return end
        if not rest:find("{spell}", 1, true) then say("the text needs {spell} in it."); return end
        db[field] = rest
        say(cmd .. " set to: " .. rest)
    elseif cmd == "test" then
        local spell = spellLabel(SPELLS[1])
        say("whisper would be: " .. fill(db.whisperText, { spell = spell, target = "Friend" }))
        say("group would be: " .. fill(db.groupText, { spell = spell, target = "Friend" }))
    elseif cmd == "reset" then
        for k in pairs(db) do db[k] = nil end
        copyDefaults(DEFAULTS, db)
        say("settings reset.")
    else
        help()
    end
end
