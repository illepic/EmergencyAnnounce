-- luacheck settings: run `luacheck .` in this folder.
std = "lua51"
max_line_length = false
self = false   -- methods (EA:Name) may leave self unused
exclude_files = { "Libs/", "dist/" }

-- Saved settings, written by the game.
globals = { "EmergencyAnnounceDB" }

-- WoW API the addon reads. Add a name here when the code starts using it.
read_globals = {
    "LibStub", "CreateFrame", "issecretvalue", "strtrim", "CopyTable", "ChatTypeInfo", "Settings",
    "C_Spell", "C_ChatInfo", "C_AddOns",
    "UnitClass", "UnitName", "GetUnitName", "UnitIsPlayer", "UnitIsUnit", "UnitIsGroupLeader", "UnitIsGroupAssistant",
    "IsInRaid", "IsInGroup", "GetNumGroupMembers", "GetNumSubgroupMembers", "GetTime",
    "LE_PARTY_CATEGORY_INSTANCE", "LE_PARTY_CATEGORY_HOME",
}
