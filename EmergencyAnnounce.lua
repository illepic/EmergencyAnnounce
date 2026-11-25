-- EmergencyAnnounce announces two kinds of spell the moment they land:
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

local ADDON, ns = ...
local EA = LibStub("AceAddon-3.0"):NewAddon(ns, ADDON, "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON)

local byName = {}   -- spell name in the player's language -> spell entry
local pending

local function readable(v)
    return not issecretvalue or not issecretvalue(v)
end

local function spellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    return (GetSpellInfo(id))
end

-- The spells for your class, or an empty list.
function EA:MySpells()
    local _, class = UnitClass("player")
    return ns.SPELLS[class] or {}
end

function EA:SpellLabel(s)
    return spellName(s.id) or s.key
end

-- Fill {spell} and {target} into a message.
function EA:Fill(text, spell, target)
    return (text:gsub("{(%a+)}", function(k)
        if k == "spell" then return spell elseif k == "target" then return target end
    end))
end

function EA:OnInitialize()
    local spells = {}
    for _, list in pairs(ns.SPELLS) do
        for _, s in ipairs(list) do spells[s.key] = s.on end
    end
    self.db = LibStub("AceDB-3.0"):New("EmergencyAnnounceDB", {
        profile = {
            whisper = true,                       -- whisper the person a protective cooldown lands on (never yourself)
            group = true,                         -- party / raid / instance chat, for both kinds
            raid = "raid",                        -- in a raid: "raid", "warning", "subgroup" or "off"
            whisperText = L["{spell} on you!"],   -- protective cooldowns on others: the whisper
            groupText = L["{spell} on {target}"], -- protective cooldowns on others: the group message
            selfText = L["Used {spell}!"],        -- your own defensive cooldowns: the group message
            spells = spells,
        },
    }, true)
    self:SetupOptions()
end

function EA:OnEnable()
    for _, list in pairs(ns.SPELLS) do
        for _, s in ipairs(list) do
            local name = spellName(s.id)
            if name then byName[name] = s end
        end
    end
    self:RegisterEvent("UNIT_SPELLCAST_SENT")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

-- The unit for a name we can see (group, target, mouseover, focus), so an NPC
-- never gets whispered and players from other realms get their full name.
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

-- Where the group message goes. In a raid the player chooses: raid chat, raid
-- warning (only raid leader and assistants may send it, so anyone else falls
-- back to raid chat), their own subgroup (party chat), or nothing.
local function groupChannel(raidChoice)
    if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
        and not IsInGroup(LE_PARTY_CATEGORY_HOME) then
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

function EA:Announce(spell, target, kind)
    local p = self.db.profile
    local channel = p.group and groupChannel(p.raid)
    if kind == "self" then
        -- Your own defensive cooldown: the group needs to know, there's nobody to whisper.
        if channel and not send(self:Fill(p.selfText, spell, UnitName("player")), channel) then
            self:Print(L["Chat was blocked, so %s on %s wasn't announced."]:format(spell, target))
        end
        return
    end

    -- A protective cooldown on someone: whisper them, tell the group.
    local isMe = target == UnitName("player")
    local ok = true
    if p.whisper and not isMe then
        local unit = findUnit(target)
        if unit then
            ok = send(self:Fill(p.whisperText, spell, target), "WHISPER", GetUnitName(unit, true) or target) and ok
        end
    end
    if channel then
        ok = send(self:Fill(p.groupText, spell, isMe and L["myself"] or target), channel) and ok
    end
    if not ok then
        self:Print(L["Chat was blocked, so %s on %s wasn't announced."]:format(spell, target))
    end
end

-- SENT: you pressed the spell. Remember the cast, announce nothing yet.
function EA:UNIT_SPELLCAST_SENT(_, unit, target, castGUID, spellID)
    if unit ~= "player" then return end
    if not (readable(target) and readable(castGUID) and readable(spellID)) then return end
    local name = spellName(spellID)
    local s = name and byName[name]
    if not s or not self.db.profile.spells[s.key] then return end
    if s.kind == "self" or not target or target == "" then target = UnitName("player") end
    pending = { guid = castGUID, spell = name, target = target, kind = s.kind, at = GetTime() }
end

-- SUCCEEDED: the server confirms that same cast went off. Only now announce.
function EA:UNIT_SPELLCAST_SUCCEEDED(_, unit, castGUID)
    if unit ~= "player" or not readable(castGUID) or not pending or pending.guid ~= castGUID then return end
    local p = pending
    pending = nil
    if GetTime() - p.at < 5 then self:Announce(p.spell, p.target, p.kind) end
end
