-- EmergencyAnnounce announces two kinds of spell the moment your cast succeeds:
--   * protective cooldowns you cast on others (Blessing of Protection,
--     Innervate, Rebirth...): whisper the person and tell your group;
--   * your own defensive cooldowns (Last Stand, Shield Wall, Frenzied
--     Regeneration...): tell your group.
-- Only successful casts are announced, so pressing the key repeatedly, being
-- out of range or on cooldown never sends anything.
-- The spells are in Spells.lua, the options in Options.lua.
--
-- Copyright (C) 2026 Garreth Stonecrash
-- Licensed under the GNU General Public License v3.0 or later. See LICENSE.

-- ADDON: this addon's folder name ("EmergencyAnnounce").
-- ns: a table the game gives every file of this addon, shared between them.
local ADDON, ns = ...

-- The addon object. AceAddon turns ns into it, so every file reaches it as ns.
-- AceConsole adds Print and RegisterChatCommand.
local EA = LibStub("AceAddon-3.0"):NewAddon(ns, ADDON, "AceConsole-3.0")

-- All player-facing text, looked up by its English wording (Locales\enUS.lua).
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON)

-- Your class's spells from Spells.lua, by their name in your language. A cast
-- is looked up here by name, so every rank of a spell finds the same entry.
local byName = {}

-- Every spell ID you've cast this session -> its entry in Spells.lua, or false
-- if EmergencyAnnounce doesn't announce it. Saves looking up the name again.
local byID = {}

-- Your character's name, read once at login. Only written into messages, never
-- compared: who's who is decided by unit (UnitIsUnit), not by name.
local me

-- The cast you just pressed, waiting for the game to confirm it succeeded:
-- { guid = cast ID, spell = chat link, target = name (nil: on yourself),
--   kind = "help"/"self", at = time pressed }. nil when nothing is waiting.
local pending

-- Forever can hide some values from addons; comparing a hidden value is an error.
local function readable(v)
    return not issecretvalue(v)
end

-- A spell's name in the player's language, from its spell ID.
local spellName = C_Spell.GetSpellName

-- A chat link to a spell ID (so its tooltip shows that exact rank) whose text
-- is just the spell's name (the entry's `name`). The game's own link text adds
-- "(Rank 2)" for spells with several ranks, which chat garbles and which we
-- don't want shown.
function EA:SpellLink(spellID, name)
    return (C_Spell.GetSpellLink(spellID):gsub("%[.-%]", function() return "[" .. name .. "]" end, 1))
end

-- The Spells.lua entry for a spell ID you cast, or false if we don't announce
-- it. Looked up by name the first time, then remembered in byID.
local function entryFor(spellID)
    local s = byID[spellID]
    if s == nil then
        s = byName[spellName(spellID)] or false
        byID[spellID] = s
    end
    return s
end

-- EmergencyAnnounce's spells for your class (from Spells.lua), learned or not.
-- An empty list if your class has none.
function EA:ClassSpells()
    local _, class = UnitClass("player")   -- "PALADIN", "DRUID"... in every language
    return ns.SPELLS[class] or {}
end

-- Fill {spell} and {target} into a message. Any other {word}, such as the
-- raid markers {skull} or {star}, is left for the game's chat to handle.
function EA:Fill(text, spell, target)
    return (text:gsub("{(%a+)}", function(k)
        if k == "spell" then return spell elseif k == "target" then return target end
    end))
end

-- AceAddon calls this once, when the addon has loaded: set up the saved
-- settings and the options page.
function EA:OnInitialize()
    -- Each spell's default on/off, by its key ("bop" = true...).
    local spells = {}
    for _, list in pairs(ns.SPELLS) do
        for _, s in ipairs(list) do spells[s.key] = s.on end
    end
    -- Saved settings in EmergencyAnnounceDB, with profiles. `true` makes every
    -- character start on the shared "Default" profile.
    self.db = LibStub("AceDB-3.0"):New("EmergencyAnnounceDB", {
        profile = {
            whisper = true,                       -- whisper the person you cast a protective cooldown on (never yourself)
            group = true,                         -- party / raid / instance chat, for both kinds
            raid = "raid",                        -- in a raid: "raid", "warning", "subgroup" or "off"
            whisperText = L["{spell} on you!"],   -- protective cooldowns on others: the whisper
            groupText = L["{spell} on {target}"], -- protective cooldowns on others: the group message
            selfText = L["Used {spell}!"],        -- your own defensive cooldowns: the group message
            spells = spells,                      -- each spell on or off, by key
        },
    }, true)
    self:SetupOptions()
end

-- AceAddon calls this when you log in: read your name, learn the spell names
-- and start listening for casts.
function EA:OnEnable()
    me = UnitName("player")
    self.playerName = me   -- for the previews in Options.lua

    -- Each spell's name, looked up once and kept on its entry as `name`. Every
    -- class's spells get one, since the options previews borrow other classes'
    -- spells as examples. Only your own class's go into byName.
    for _, list in pairs(ns.SPELLS) do
        for _, s in ipairs(list) do s.name = spellName(s.id) end
    end
    for _, s in ipairs(self:ClassSpells()) do byName[s.name] = s end

    -- Only your own casts: the game itself filters these events to "player",
    -- so other players' casts never reach the addon. Each event calls the
    -- method of the same name below.
    local frame = CreateFrame("Frame")
    frame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")
    frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    frame:SetScript("OnEvent", function(_, event, ...) self[event](self, ...) end)
end

-- The unit for a name we can see (you, group, target, mouseover, focus), so an
-- NPC never gets whispered and players from other realms get their full name.
-- nil if no player by that name is in sight.
local function findUnit(name)
    -- You first, then where a cast's target usually is, then everyone in your group.
    local units = { "player", "target", "mouseover", "targettarget", "focus" }
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do units[#units + 1] = "raid" .. i end
    else
        for i = 1, GetNumSubgroupMembers() do units[#units + 1] = "party" .. i end
    end
    for _, unit in ipairs(units) do
        -- short: "Thrall". full: "Thrall-Realm" for players from another realm.
        local short, full = UnitName(unit), GetUnitName(unit, true)
        if readable(short) and readable(full) and (short == name or full == name) and UnitIsPlayer(unit) then
            return unit
        end
    end
end

-- Send one chat message. channel: "WHISPER", "PARTY", "RAID"...; who: the
-- player to whisper. Returns false if the game is blocking addon chat right
-- now or refuses the message, so the caller can tell the player instead of
-- showing a Lua error.
local function send(msg, channel, who)
    if C_ChatInfo.InChatMessagingLockdown() then return false end
    return (pcall(C_ChatInfo.SendChatMessage, msg, channel, nil, who))
end

-- Where the group message goes, or nil for nowhere. In a raid the player
-- chooses (raidChoice): raid chat, raid warning (only raid leader and
-- assistants may send it, so anyone else falls back to raid chat), their own
-- subgroup (party chat), or nothing.
local function groupChannel(raidChoice)
    -- A group the game made for you (dungeon finder, battleground).
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "INSTANCE_CHAT"
    end
    if IsInRaid() then
        if raidChoice == "off" then return nil end
        if raidChoice == "subgroup" then return "PARTY" end
        if raidChoice == "warning" and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
            return "RAID_WARNING"
        end
        return "RAID"
    end
    if IsInGroup() then return "PARTY" end
end

-- Send the messages for one successful cast. spell: the spell's chat link;
-- target: the name it was cast on, or nil for yourself; kind: "help"
-- (protective cooldown on others) or "self" (your own defensive cooldown).
function EA:Announce(spell, target, kind)
    local p = self.db.profile   -- the current profile's settings
    local channel = p.group and groupChannel(p.raid)   -- nil: no group message
    if kind == "self" then
        -- Your own defensive cooldown: the group needs to know, there's nobody to whisper.
        if channel and not send(self:Fill(p.selfText, spell, me), channel) then
            self:Print(L["Chat was blocked, so %s wasn't announced."]:format(spell))
        end
        return
    end

    -- A protective cooldown on someone: whisper them, tell the group. On
    -- yourself (no target, or the unit found is you): no whisper. Decided by
    -- unit, never by name: a cast can carry your name with your surname.
    local unit = target and findUnit(target)
    local mine = unit and UnitIsUnit(unit, "player")
    local isMe = not target or (readable(mine) and mine)
    local who = isMe and L["myself"] or target   -- the name the group message shows
    local ok = true                              -- false once any message fails
    if p.whisper and unit and not isMe then
        ok = send(self:Fill(p.whisperText, spell, target), "WHISPER", GetUnitName(unit, true)) and ok
    end
    if channel then
        ok = send(self:Fill(p.groupText, spell, who), channel) and ok
    end
    if not ok then
        self:Print(L["Chat was blocked, so %s on %s wasn't announced."]:format(spell, who))
    end
end

-- SENT: you pressed the spell. Remember the cast, announce nothing yet.
-- {spell} becomes a chat link to the exact rank you cast, so anyone can hover
-- or click it for the game's own tooltip.
-- target: the target's name ("" or nil for none); castGUID: the game's ID for
-- this one cast; spellID: the exact rank cast. (The first value, the unit, is
-- always "player".)
function EA:UNIT_SPELLCAST_SENT(_, target, castGUID, spellID)
    if not (readable(target) and readable(castGUID) and readable(spellID)) then return end
    local s = entryFor(spellID)   -- the spell's entry, or false if we don't announce it
    if not s or not self.db.profile.spells[s.key] then return end
    -- Your own defensive cooldowns, and casts sent without a target, are on you.
    if s.kind == "self" or target == "" then target = nil end
    pending = { guid = castGUID, spell = self:SpellLink(spellID, s.name), target = target, kind = s.kind, at = GetTime() }
end

-- SUCCEEDED: the server confirms that same cast went off. Only now announce.
-- castGUID must match the cast remembered at SENT, within 5 seconds.
-- (The first value, the unit, is always "player".)
function EA:UNIT_SPELLCAST_SUCCEEDED(_, castGUID)
    if not readable(castGUID) or not pending or pending.guid ~= castGUID then return end
    local cast = pending
    pending = nil
    if GetTime() - cast.at < 5 then self:Announce(cast.spell, cast.target, cast.kind) end
end
