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
L["Announces your protective cooldowns on others and your own defensive cooldowns the moment they land."] = true
L["Version %s"] = true
L["To %s: %s"] = true                -- live preview of a whisper you send
L["[Party] %s: %s"] = true           -- live preview of a party message
L["Announce"] = true
L["Whisper the target"] = true
L["Whisper the person your protective cooldown lands on. Never yourself, never an NPC."] = true
L["Tell my group"] = true
L["Announce in party, raid or instance chat. Not in a group, only the whisper is sent."] = true
L["Whispered to the person your protective cooldown lands on."] = true
L["Sent to your group when your protective cooldown lands on someone."] = true
L["Repeat delay"] = true
L["Seconds before the same spell on the same person is announced again."] = true
L["Group messages go to party chat in a party, raid chat in a raid, and instance chat in groups the game made for you (dungeon finder, battlegrounds)."] = true
L["Not in a group: a protective cooldown on someone, such as a stranger you save while questing, is only whispered to them. Your own defensive cooldowns aren't announced, since there's no group to tell."] = true
L["Messages"] = true
L["Whisper text"] = true
L["Group text"] = true
L["{spell} is replaced with the spell you cast. {target} is replaced with the name of the person you cast it on."] = true
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
