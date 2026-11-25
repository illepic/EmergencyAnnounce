-- English text for EmergencyAnnounce: the options page, the default wording
-- for protective cooldowns on others and for your own defensive cooldowns,
-- and chat lines. Other languages go in their own file next to this one.
-- L: the English text. `true` makes English the default, used for any text
-- another language doesn't have. Each line below sets a text to itself.
local L = LibStub("AceLocale-3.0"):NewLocale("EmergencyAnnounce", "enUS", true)
-- AceLocale returns nil when this language isn't needed; then skip the file.
if not L then return end

-- Default message text (players can change it in the options)
L["{spell} on you!"] = true          -- protective cooldown on others: the whisper
L["{spell} on {target}"] = true      -- protective cooldown on others: the group message
L["Used {spell}!"] = true            -- your own defensive cooldown: the group message
L["myself"] = true

-- Options
L["Announces your protective cooldowns on others and your own defensive cooldowns the moment your cast succeeds."] = true
L["Version %s"] = true
L["To %s: %s"] = true                -- live preview of a whisper you send
L["[Party] %s: %s"] = true           -- live preview of a party message
L["Announce"] = true
L["Whisper the target"] = true
L["Whisper the person you cast your protective cooldown on. Never yourself, never an NPC."] = true
L["Tell my group"] = true
L["Announce in party, raid or instance chat. Not in a group, only the whisper is sent."] = true
L["Whispered to the person you cast your protective cooldown on."] = true
L["Sent to your group when you cast your protective cooldown on someone."] = true
L["Group messages go to party chat in a party and instance chat in groups the game made for you (dungeon finder, battlegrounds). In a raid, you choose above: raid chat, raid warning, your own subgroup, or nothing."] = true
L["In a raid"] = true
L["Raid warning needs raid leader or assistant; otherwise it goes to raid chat."] = true
L["Raid chat"] = true
L["Raid warning"] = true
L["My subgroup only"] = true
L["Don't announce"] = true
L["Not in a group: a protective cooldown on someone, such as a stranger you save while questing, is only whispered to them. Your own defensive cooldowns aren't announced, since there's no group to tell."] = true
L["Messages"] = true
L["Whisper text"] = true
L["Group text"] = true
L["{spell} is replaced with a link to the spell you cast. {target} is replaced with the name of the person you cast it on."] = true
L["The text needs {spell} in it."] = true
L["Keep the text to %d characters or fewer."] = true
L["Preview"] = true
L["Show both messages in your own chat. Nothing is sent."] = true
L["Whisper: %s"] = true
L["Group: %s"] = true
L["Friend"] = true
L["Protective cooldowns on others"] = true
L["My defensive cooldowns"] = true
L["Defensive cooldown text"] = true
L["Sent to your group when you use one of your own defensive cooldowns."] = true
L["Announce %s when your cast succeeds."] = true
L["Your class has no spells EmergencyAnnounce announces."] = true
L["Profiles"] = true

-- Chat
L["Chat was blocked, so %s on %s wasn't announced."] = true
L["Chat was blocked, so %s wasn't announced."] = true
