-- The options page (Esc > Options > AddOns > EmergencyAnnounce) and the /ea
-- commands, both built by AceConfig from the one table below. Your class's
-- spells appear in two sections: protective cooldowns on others and your own
-- defensive cooldowns, each with its own wording. Profiles come from
-- AceDBOptions.

local ADDON, ns = ...
local EA = ns
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON)

local function needsSpell(_, value)
    if not value:find("{spell}", 1, true) then return L["The text needs {spell} in it."] end
    return true
end

-- Your class's first spell of a kind ("help" = protective cooldown on others,
-- "self" = your own defensive cooldown), as a name for the preview.
local function firstOf(kind)
    for _, s in ipairs(EA:MySpells()) do
        if s.kind == kind then return EA:SpellLabel(s) end
    end
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
                desc = function() return L["Announce %s when it lands."]:format(EA:SpellLabel(s)) end,
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
            announce = {
                type = "group", inline = true, order = 1, name = L["Announce"],
                args = {
                    whisper = { type = "toggle", order = 1, name = L["Whisper the target"],
                        desc = L["Whisper the person your protective cooldown lands on. Never yourself, never an NPC."] },
                    group = { type = "toggle", order = 2, name = L["Tell my group"],
                        desc = L["Announce in party, raid or instance chat. Solo, only the whisper is sent."] },
                    throttle = { type = "range", order = 3, name = L["Repeat delay"],
                        desc = L["Seconds before the same spell on the same person is announced again."],
                        min = 0, max = 300, step = 1 },
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
                    whisperText = { type = "input", order = 1, width = "full", name = L["Whisper text"],
                        desc = L["Whispered to the person your protective cooldown lands on."],
                        validate = needsSpell },
                    groupText = { type = "input", order = 2, width = "full", name = L["Group text"],
                        desc = L["Sent to your group when your protective cooldown lands on someone."],
                        validate = needsSpell },
                    selfText = { type = "input", order = 3, width = "full", name = L["Defensive cooldown text"],
                        desc = L["Sent to your group when you use one of your own defensive cooldowns."],
                        validate = needsSpell },
                    help = { type = "description", order = 4, name = L["{spell} and {target} are filled in for you."] },
                    test = { type = "execute", order = 5, name = L["Preview"],
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

    AceConfig:RegisterOptionsTable(ADDON .. "_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    AceConfigDialog:AddToBlizOptions(ADDON .. "_Profiles", L["Profiles"], ADDON)

    self:RegisterChatCommand("ea", "ChatCommand")
    self:RegisterChatCommand("emergencyannounce", "ChatCommand")
end

-- /ea opens the options page; /ea <option> [value] changes one setting;
-- /ea help lists them.
function EA:ChatCommand(input)
    input = strtrim(input or "")
    if input == "" then
        if Settings and Settings.OpenToCategory and self.categoryID then
            Settings.OpenToCategory(self.categoryID)
        else
            LibStub("AceConfigDialog-3.0"):Open(ADDON)
        end
        return
    end
    if input:lower() == "help" then input = "" end
    LibStub("AceConfigCmd-3.0"):HandleCommand("ea", ADDON, input)
end
