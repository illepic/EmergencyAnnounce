-- The options page (Esc > Options > AddOns > EmergencyAnnounce) and the /ea
-- commands, both built by AceConfig from the one table below. Your class's
-- spells appear in two sections: protective cooldowns on others and your own
-- defensive cooldowns, each with its own wording. Profiles come from
-- AceDBOptions.

-- ADDON: this addon's folder name. ns: the table shared by this addon's files.
local ADDON, ns = ...
-- The addon object, made from ns in EmergencyAnnounce.lua.
local EA = ns
-- All player-facing text (Locales\enUS.lua).
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON)

-- The addon's icon (the game's own Battle Shout icon), shown in the introduction.
local ICON = "Interface\\Icons\\Ability_Warrior_BattleShout"
-- Crop the icon's built-in border: left, right, top, bottom, as fractions.
local TRIM = { 0.07, 0.93, 0.07, 0.93 }

-- Chat messages stop at 255 bytes. Leave room for what gets filled in: the
-- spell link (about 60 bytes) and the target's name.
local MAX_TEXT = 150

-- Checks a message typed in the options or with /ea ...text. AceConfig shows
-- a returned string as the error and keeps the old text; true accepts it.
local function checkText(_, value)
    if not value:find("{spell}", 1, true) then return L["The text needs {spell} in it."] end
    if #value > MAX_TEXT then return L["Keep the text to %d characters or fewer."]:format(MAX_TEXT) end
    return true
end

-- The game's own icon for a spell (its first rank), for its checkbox.
local function spellIcon(s)
    return C_Spell.GetSpellTexture(s.id)
end

-- The tooltip for a spell's checkbox: the game's own description of the spell
-- (its first rank), then a grey line saying what the checkbox does.
local function spellTooltip(s)
    local text = C_Spell.GetSpellDescription(s.id)
    local line = L["Announce %s when your cast succeeds."]:format(EA:SpellLabel(s))
    if text ~= "" then return text .. "\n\n|cff999999" .. line .. "|r" end
    return line
end

-- Your class's first spell of a kind ("help" = protective cooldown on others,
-- "self" = your own defensive cooldown), as a chat link for the previews.
-- nil if your class has none of that kind.
local function firstOf(kind)
    for _, s in ipairs(EA:ClassSpells()) do
        if s.kind == kind then return C_Spell.GetSpellLink(s.id) end
    end
end

-- An example spell of a kind: yours if your class has one, else any class's.
-- Used by the live previews, which show every message whatever your class.
local function exampleSpell(kind)
    local mine = firstOf(kind)
    if mine then return mine end
    for _, list in pairs(ns.SPELLS) do
        for _, s in ipairs(list) do
            if s.kind == kind then return C_Spell.GetSpellLink(s.id) end
        end
    end
end

-- Text in the colour the game's chat uses for that kind of message
-- (chatType: "WHISPER_INFORM", "PARTY"...).
local function inChatColor(chatType, text)
    local c = ChatTypeInfo[chatType]   -- the colour, as r, g, b from 0 to 1
    -- One colour channel from 0-1 to 0-255, for the |cffRRGGBB colour code.
    local function byte(v) return math.floor(v * 255 + 0.5) end
    return ("|cff%02x%02x%02x%s|r"):format(byte(c.r), byte(c.g), byte(c.b), text)
end

-- How a message will look in chat, for the live previews under the text boxes.
-- field: which message, "whisperText", "groupText" or "selfText".
local function previewLine(field)
    local p, me = EA.db.profile, EA.playerName   -- settings, your name
    if field == "whisperText" then
        local msg = EA:Fill(p.whisperText, exampleSpell("help"), L["Friend"])
        return inChatColor("WHISPER_INFORM", L["To %s: %s"]:format(L["Friend"], msg))
    end
    local text = field == "selfText" and EA:Fill(p.selfText, exampleSpell("self"), me)
        or EA:Fill(p.groupText, exampleSpell("help"), L["Friend"])
    return inChatColor("PARTY", L["[Party] %s: %s"]:format(me, text))
end

-- The Preview button and /ea test: print your messages, filled in with your
-- class's spells, in your own chat. Nothing is sent.
function EA:Preview()
    local p = self.db.profile
    local help, own = firstOf("help"), firstOf("self")   -- nil if your class has none of that kind
    if help then
        self:Print(L["Whisper: %s"]:format(self:Fill(p.whisperText, help, L["Friend"])))
        self:Print(L["Group: %s"]:format(self:Fill(p.groupText, help, L["Friend"])))
    end
    if own then
        self:Print(L["Group: %s"]:format(self:Fill(p.selfText, own, self.playerName)))
    end
end

-- One checkbox per spell of your class and of this kind. Returns the
-- checkboxes (by spell key, for AceConfig) and how many there are.
local function spellToggles(kind)
    local args, n = {}, 0
    for _, s in ipairs(EA:ClassSpells()) do
        if s.kind == kind then
            n = n + 1
            args[s.key] = {
                type = "toggle", order = n,
                name = function() return EA:SpellLabel(s) end,
                desc = function() return spellTooltip(s) end,
                image = function() return spellIcon(s) end,
                imageCoords = TRIM,
                get = function() return EA.db.profile.spells[s.key] end,
                set = function(_, v) EA.db.profile.spells[s.key] = v end,
            }
        end
    end
    return args, n
end

-- The whole options table, which AceConfig turns into both the options page
-- and the /ea commands. Each entry's key is also its /ea command name.
function EA:GetOptions()
    local helpArgs, helpCount = spellToggles("help")   -- protective cooldowns on others
    local selfArgs, selfCount = spellToggles("self")   -- your own defensive cooldowns
    -- A line saying your class has nothing to announce (Shaman, for example).
    local noSpells
    if helpCount + selfCount == 0 then
        noSpells = { type = "description", order = 2, name = L["Your class has no spells EmergencyAnnounce announces."] }
    end

    return {
        type = "group",
        name = ADDON,
        -- By default, each option reads and writes the profile setting of the
        -- same name (whisper, group, raid, whisperText...).
        get = function(info) return self.db.profile[info[#info]] end,
        set = function(info, v) self.db.profile[info[#info]] = v end,
        args = {
            -- The icon, one line about the addon, and its version.
            intro = {
                type = "description", order = 0, fontSize = "medium",
                image = ICON, imageCoords = TRIM, imageWidth = 40, imageHeight = 40,
                name = function()
                    local version = C_AddOns.GetAddOnMetadata(ADDON, "Version")   -- from the .toc
                    return L["Announces your protective cooldowns on others and your own defensive cooldowns the moment your cast succeeds."]
                        .. "\n|cff999999" .. L["Version %s"]:format(version) .. "|r"
                end,
            },
            -- Who gets told: the whisper, the group message, and where it goes in a raid.
            announce = {
                type = "group", inline = true, order = 1, name = L["Announce"],
                args = {
                    whisper = { type = "toggle", order = 1, name = L["Whisper the target"],
                        desc = L["Whisper the person you cast your protective cooldown on. Never yourself, never an NPC."] },
                    group = { type = "toggle", order = 2, name = L["Tell my group"],
                        desc = L["Announce in party, raid or instance chat. Not in a group, only the whisper is sent."] },
                    raid = { type = "select", order = 3, name = L["In a raid"],
                        desc = L["Raid warning needs raid leader or assistant; otherwise it goes to raid chat."],
                        values = { raid = L["Raid chat"], warning = L["Raid warning"],
                            subgroup = L["My subgroup only"], off = L["Don't announce"] },
                        sorting = { "raid", "warning", "subgroup", "off" },
                        disabled = function() return not EA.db.profile.group end },
                    channels = { type = "description", order = 4,
                        name = "\n" .. L["Group messages go to party chat in a party and instance chat in groups the game made for you (dungeon finder, battlegrounds). In a raid, you choose above: raid chat, raid warning, your own subgroup, or nothing."]
                            .. "\n" .. L["Not in a group: a protective cooldown on someone, such as a stranger you save while questing, is only whispered to them. Your own defensive cooldowns aren't announced, since there's no group to tell."] },
                },
            },
            none = noSpells,
            -- One checkbox per protective cooldown on others; hidden if your class has none.
            spells = {
                type = "group", inline = true, order = 2, name = L["Protective cooldowns on others"],
                hidden = helpCount == 0,
                args = helpArgs,
            },
            -- One checkbox per defensive cooldown of your own; hidden if your class has none.
            cooldowns = {
                type = "group", inline = true, order = 3, name = L["My defensive cooldowns"],
                hidden = selfCount == 0,
                args = selfArgs,
            },
            -- The three messages, each with a live preview, and the Preview button.
            messages = {
                type = "group", inline = true, order = 4, name = L["Messages"],
                args = {
                    placeholders = { type = "description", order = 0,
                        name = L["{spell} is replaced with a link to the spell you cast. {target} is replaced with the name of the person you cast it on."] .. "\n" },
                    whisperText = { type = "input", order = 1, width = "full", name = L["Whisper text"],
                        desc = L["Whispered to the person you cast your protective cooldown on."],
                        validate = checkText },
                    whisperPreview = { type = "description", order = 2, name = function() return previewLine("whisperText") end },
                    groupText = { type = "input", order = 3, width = "full", name = L["Group text"],
                        desc = L["Sent to your group when you cast your protective cooldown on someone."],
                        validate = checkText },
                    groupPreview = { type = "description", order = 4, name = function() return previewLine("groupText") end },
                    selfText = { type = "input", order = 5, width = "full", name = L["Defensive cooldown text"],
                        desc = L["Sent to your group when you use one of your own defensive cooldowns."],
                        validate = checkText },
                    selfPreview = { type = "description", order = 6, name = function() return previewLine("selfText") end },
                    test = { type = "execute", order = 7, name = L["Preview"],
                        desc = L["Show both messages in your own chat. Nothing is sent."],
                        func = function() self:Preview() end },
                },
            },
        },
    }
end

-- Register the options page, its Profiles sub-page and the /ea commands.
-- Called once from OnInitialize.
function EA:SetupOptions()
    local AceConfig, AceConfigDialog = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")
    AceConfig:RegisterOptionsTable(ADDON, self:GetOptions())
    -- The page's ID in the game's Settings window, so /ea can open it.
    local _, categoryID = AceConfigDialog:AddToBlizOptions(ADDON, ADDON)
    self.categoryID = categoryID

    -- The Profiles page, made by AceDBOptions from our saved settings.
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    -- Ace3 shares this page layout with every addon, so widen the "Current
    -- Profile" line in our own copy only: Forever names ("Garreth Stonecrash")
    -- don't fit its default width and wrap onto two lines.
    profiles.args = CopyTable(profiles.args)
    profiles.args.current.width = "double"
    AceConfig:RegisterOptionsTable(ADDON .. "_Profiles", profiles)
    AceConfigDialog:AddToBlizOptions(ADDON .. "_Profiles", L["Profiles"], ADDON)

    self:RegisterChatCommand("ea", "ChatCommand")
    self:RegisterChatCommand("emergencyannounce", "ChatCommand")
end

-- /ea opens the options page; /ea <option> [value] changes one setting;
-- /ea help lists them. input: whatever was typed after the command.
function EA:ChatCommand(input)
    input = strtrim(input)
    if input == "" then
        Settings.OpenToCategory(self.categoryID)
        return
    end
    -- AceConfigCmd lists every option when given nothing.
    if input:lower() == "help" then input = "" end
    LibStub("AceConfigCmd-3.0"):HandleCommand("ea", ADDON, input)
end
