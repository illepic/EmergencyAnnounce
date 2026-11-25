-- English text for EmergencyAnnounce: the options page, the default wording
-- for protective cooldowns on others and for your own defensive cooldowns,
-- and chat lines. Other languages go in their own file next to this one.
local L = LibStub("AceLocale-3.0"):NewLocale("EmergencyAnnounce", "enUS", true)
if not L then return end

-- Default message text (players can change it in the options)
L["{spell} on you!"] = true          -- protective cooldown on others: the whisper
L["{spell} on {target}"] = true      -- protective cooldown on others: the group message
L["Used {spell}!"] = true            -- your own defensive cooldown: the group message
L["myself"] = true

-- Options
L["Announce"] = true
L["Whisper the target"] = true
L["Whisper the person your protective cooldown lands on. Never yourself, never an NPC."] = true
L["Tell my group"] = true
L["Announce in party, raid or instance chat. Solo, only the whisper is sent."] = true
L["Whispered to the person your protective cooldown lands on."] = true
L["Sent to your group when your protective cooldown lands on someone."] = true
L["Repeat delay"] = true
L["Seconds before the same spell on the same person is announced again."] = true
L["Messages"] = true
L["Whisper text"] = true
L["Group text"] = true
L["{spell} and {target} are filled in for you."] = true
L["The text needs {spell} in it."] = true
L["Preview"] = true
L["Show both messages in your own chat. Nothing is sent."] = true
L["Whisper: %s"] = true
L["Group: %s"] = true
L["Friend"] = true
L["Protective cooldowns on others"] = true
L["My defensive cooldowns"] = true
L["Defensive cooldown text"] = true
L["Sent to your group when you use one of your own defensive cooldowns."] = true
L["Announce %s when it lands."] = true
L["Your class has no spells EmergencyAnnounce announces."] = true
L["Profiles"] = true

-- Chat
L["Chat was blocked, so %s on %s wasn't announced."] = true
