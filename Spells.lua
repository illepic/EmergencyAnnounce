-- The spells EmergencyAnnounce can announce, by class. Each spell is listed by
-- one spell ID; the game turns it into the spell's name in the player's
-- language, and a cast is matched by that name, so every rank counts.
-- `on` is the default, and each player can change it in the options.
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
        { key = "bop",              kind = "help", id = 1022,    on = true  }, -- Blessing of Protection
        { key = "freedom",          kind = "help", id = 1044,    on = true  }, -- Blessing of Freedom
        { key = "di",               kind = "help", id = 19752,   on = true  }, -- Divine Intervention
        { key = "loh",              kind = "help", id = 633,     on = false }, -- Lay on Hands: nothing for the target to react to
        { key = "sacrifice",        kind = "help", id = 6940,    on = false }, -- Blessing of Sacrifice
        { key = "divineshield",     kind = "self", id = 642,     on = false }, -- Divine Shield
        { key = "divineprotection", kind = "self", id = 498,     on = false }, -- Divine Protection
        { key = "bulwark",          kind = "self", id = 1311015, on = false }, -- Templar's Bulwark (Forever)
    },
    WARRIOR = {
        { key = "laststand",        kind = "self", id = 12975,   on = true  }, -- Last Stand
        { key = "shieldwall",       kind = "self", id = 871,     on = true  }, -- Shield Wall
        { key = "retaliation",      kind = "self", id = 20230,   on = false }, -- Retaliation
    },
    DRUID = {
        { key = "innervate",        kind = "help", id = 29166,   on = true  }, -- Innervate
        { key = "rebirth",          kind = "help", id = 20484,   on = true  }, -- Rebirth
        { key = "frenziedregen",    kind = "self", id = 22842,   on = true  }, -- Frenzied Regeneration
        { key = "barkskin",         kind = "self", id = 22812,   on = false }, -- Barkskin
    },
    PRIEST = {
        { key = "fearward",         kind = "help", id = 6346,    on = true  }, -- Fear Ward
        { key = "pi",               kind = "help", id = 10060,   on = false }, -- Power Infusion
    },
    WARLOCK = {
        { key = "soulstone",        kind = "help", id = 20707,   on = true  }, -- Soulstone Resurrection
    },
    MAGE = {
        { key = "iceblock",         kind = "self", id = 11958,   on = false }, -- Ice Block
    },
    ROGUE = {
        { key = "evasion",          kind = "self", id = 5277,    on = false }, -- Evasion
    },
    HUNTER = {
        { key = "deterrence",       kind = "self", id = 19263,   on = false }, -- Deterrence
    },
}
