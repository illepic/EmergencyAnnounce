-- The options page (Esc > Options > AddOns > EmergencyAnnounce) and the /ea
-- commands, both built by AceConfig from the one table below. Your class's
-- spells appear in two sections: protective cooldowns on others and your own
-- defensive cooldowns, each with its own wording. Profiles come from
-- AceDBOptions.

local ADDON, ns = ...
local EA = ns
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON)

local ICON = "Interface\\Icons\\Ability_Warrior_BattleShout"
local TRIM = { 0.07, 0.93, 0.07, 0.93 }   -- crop the icon's built-in border

-- Chat messages stop at 255 bytes. Leave room for what gets filled in: the
-- spell link (about 60 bytes) and the target's name.
local MAX_TEXT = 150

local function checkText(_, value)
    if not value:find("{spell}", 1, true) then return L["The text needs {spell} in it."] end
    if #value > MAX_TEXT then return L["Keep the text to %d characters or fewer."]:format(MAX_TEXT) end
    return true
end

-- The game's own icon and description for a spell (its first rank).
local function spellIcon(s)
    return C_Spell.GetSpellTexture(s.id)
end

local function spellTooltip(s)
    local text = C_Spell.GetSpellDescription(s.id)
    local line = L["Announce %s when your cast succeeds."]:format(EA:SpellLabel(s))
    if text ~= "" then return text .. "\n\n|cff999999" .. line .. "|r" end
    return line
end

-- Your class's first spell of a kind ("help" = protective cooldown on others,
-- "self" = your own defensive cooldown), as a chat link for the previews.
local function firstOf(kind)
    for _, s in ipairs(EA:MySpells()) do
        if s.kind == kind then return C_Spell.GetSpellLink(s.id) end
    end
end

-- An example spell of a kind: yours if your class has one, else any class's.
local function exampleSpell(kind)
    local mine = firstOf(kind)
    if mine then return mine end
    for _, list in pairs(ns.SPELLS) do
        for _, s in ipairs(list) do
            if s.kind == kind then return C_Spell.GetSpellLink(s.id) end
        end
    end
end

-- Text in the colour the game's chat uses for that kind of message.
local function inChatColor(chatType, text)
    local c = ChatTypeInfo[chatType]
    local function byte(v) return math.floor(v * 255 + 0.5) end
    return ("|cff%02x%02x%02x%s|r"):format(byte(c.r), byte(c.g), byte(c.b), text)
end

-- How a message will look in chat, for the live previews under the text boxes.
local function previewLine(field)
    local p, me = EA.db.profile, UnitName("player")
    if field == "whisperText" then
        local msg = EA:Fill(p.whisperText, exampleSpell("help"), L["Friend"])
        return inChatColor("WHISPER_INFORM", L["To %s: %s"]:format(L["Friend"], msg))
    end
    local text = field == "selfText" and EA:Fill(p.selfText, exampleSpell("self"), me)
        or EA:Fill(p.groupText, exampleSpell("help"), L["Friend"])
    return inChatColor("PARTY", L["[Party] %s: %s"]:format(me, text))
end

function EA:Preview()
    local p = self.db.profile
    local help, own = firstOf("help"), firstOf("self")
    if help then
        self:Print(L["Whisper: %s"]:format(self:Fill(p.whisperText, help, L["Friend"])))
        self:Print(L["Group: %s"]:format(self:Fill(p.groupText, help, L["Friend"])))
    end
    if own then
        self:Print(L["Group: %s"]:format(self:Fill(p.selfText, own, UnitName("player"))))
    end
end

-- One checkbox per spell of your class and of this kind.
local function spellToggles(kind)
    local args, n = {}, 0
    for _, s in ipairs(EA:MySpells()) do
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

function EA:GetOptions()
    local helpArgs, helpCount = spellToggles("help")
    local selfArgs, selfCount = spellToggles("self")
    local noSpells
    if helpCount + selfCount == 0 then
        noSpells = { type = "description", order = 2, name = L["Your class has no spells EmergencyAnnounce announces."] }
    end

    return {
        type = "group",
        name = ADDON,
        get = function(info) return self.db.profile[info[#info]] end,
        set = function(info, v) self.db.profile[info[#info]] = v end,
        args = {
            intro = {
                type = "description", order = 0, fontSize = "medium",
                image = ICON, imageCoords = TRIM, imageWidth = 40, imageHeight = 40,
                name = function()
                    local version = C_AddOns.GetAddOnMetadata(ADDON, "Version")
                    return L["Announces your protective cooldowns on others and your own defensive cooldowns the moment your cast succeeds."]
                        .. "\n|cff999999" .. L["Version %s"]:format(version) .. "|r"
                end,
            },
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
            spells = {
                type = "group", inline = true, order = 2, name = L["Protective cooldowns on others"],
                hidden = helpCount == 0,
                args = helpArgs,
            },
            cooldowns = {
                type = "group", inline = true, order = 3, name = L["My defensive cooldowns"],
                hidden = selfCount == 0,
                args = selfArgs,
            },
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

function EA:SetupOptions()
    local AceConfig, AceConfigDialog = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")
    AceConfig:RegisterOptionsTable(ADDON, self:GetOptions())
    local _, categoryID = AceConfigDialog:AddToBlizOptions(ADDON, ADDON)
    self.categoryID = categoryID

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
-- /ea help lists them.
function EA:ChatCommand(input)
    input = strtrim(input)
    if input == "" then
        Settings.OpenToCategory(self.categoryID)
        return
    end
    if input:lower() == "help" then input = "" end
    LibStub("AceConfigCmd-3.0"):HandleCommand("ea", ADDON, input)
end
