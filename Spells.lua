-- The spells EmergencyAnnounce can announce, by class. Every rank's spell ID is
-- listed; names come from the game, so every client language works. `on` is
-- the default, and each player can change it in the options.
--
-- Two kinds:
--   help: a protective cooldown you cast on someone else. Whisper them and
--         tell the group.
--   self: your own defensive cooldown. Tell the group only.
--
-- Spells chosen because the person or the group should know right away.
-- Spell availability on WoW: Forever checked against talentsforever.com data
-- (CC BY 4.0, https://creativecommons.org/licenses/by/4.0/).

local _, ns = ...

ns.SPELLS = {
    PALADIN = {
        { key = "bop",             kind = "help", ids = { 1022, 5599, 10278 },                 on = true  }, -- Blessing of Protection
        { key = "freedom",         kind = "help", ids = { 1044 },                              on = true  }, -- Blessing of Freedom
        { key = "di",              kind = "help", ids = { 19752 },                             on = true  }, -- Divine Intervention
        { key = "loh",             kind = "help", ids = { 633, 2800, 10310 },                  on = false }, -- Lay on Hands: a big heal, nothing for the target to react to
        { key = "sacrifice",       kind = "help", ids = { 6940, 20729 },                       on = false }, -- Blessing of Sacrifice
        { key = "divineshield",    kind = "self", ids = { 642, 1020 },                         on = false }, -- Divine Shield
        { key = "divineprotection",kind = "self", ids = { 498, 5573 },                         on = false }, -- Divine Protection
        { key = "bulwark",         kind = "self", ids = { 1311015 },                           on = false }, -- Templar's Bulwark (Forever)
    },
    WARRIOR = {
        { key = "laststand",       kind = "self", ids = { 12975 },                             on = true  }, -- Last Stand
        { key = "shieldwall",      kind = "self", ids = { 871 },                               on = true  }, -- Shield Wall
        { key = "retaliation",     kind = "self", ids = { 20230 },                             on = false }, -- Retaliation
    },
    DRUID = {
        { key = "innervate",       kind = "help", ids = { 29166 },                             on = true  }, -- Innervate
        { key = "rebirth",         kind = "help", ids = { 20484, 20739, 20742, 20747, 20748 }, on = true  }, -- Rebirth
        { key = "frenziedregen",   kind = "self", ids = { 22842 },                             on = true  }, -- Frenzied Regeneration
        { key = "barkskin",        kind = "self", ids = { 22812 },                             on = false }, -- Barkskin
    },
    PRIEST = {
        { key = "fearward",        kind = "help", ids = { 6346 },                              on = true  }, -- Fear Ward
        { key = "pi",              kind = "help", ids = { 10060 },                             on = false }, -- Power Infusion
    },
    WARLOCK = {
        { key = "soulstone",       kind = "help", ids = { 20707, 20762, 20763, 20764, 20765 }, on = true  }, -- Soulstone Resurrection
    },
    MAGE = {
        { key = "iceblock",        kind = "self", ids = { 11958 },                             on = false }, -- Ice Block
    },
    ROGUE = {
        { key = "evasion",         kind = "self", ids = { 5277 },                              on = false }, -- Evasion
    },
    HUNTER = {
        { key = "deterrence",      kind = "self", ids = { 19263 },                             on = false }, -- Deterrence
    },
}
