# Changelog

## 1.3.3

- Fixed: spells with several ranks, such as Blessing of Protection, came out garbled in chat. The spell link now shows just the spell's name, with no rank; its tooltip still shows the rank you cast.

## 1.3.2

- Only ever sees your own casts: the game now passes EmergencyAnnounce your casts alone, instead of every cast around you.
- Lighter: looks up only your own class's spells, remembers each spell it has checked, and reads your name once at login.
- No longer needs the AceEvent library.

## 1.3.1

- Clearer wording: spells are announced when your cast succeeds. The README explains how a cast is confirmed and what isn't checked.
- If chat is blocked when you use one of your own defensive cooldowns, the note in your chat names just the spell.
- The spell in each message is a chat link to the exact rank you cast. Hover or click it to see the spell's tooltip.
- Message text can be up to 150 characters, so the filled-in message, link included, stays within the game's chat limit. Longer text is refused with a note instead of failing to send.
- Smaller code: uses WoW: Forever's own spell, chat and addon functions directly.

## 1.3.0

- Choose where the group message goes in a raid: raid chat (default), raid warning, your own subgroup only, or nothing. Options > Announce > In a raid, or `/ea raid <raid|warning|subgroup|off>`. Raid warning needs raid leader or assistant; otherwise the message goes to raid chat.
- Spells are matched by the game's own spell name, so every rank counts, including ranks WoW: Forever adds.
- Removed the repeat delay setting (and `/ea throttle`). Each successful cast is announced once, and these spells' cooldowns already keep announcements apart.

## 1.2.2

- Bump for publishing.

## 1.2.1

A livelier options page:

- Each spell checkbox shows the spell's icon, and hovering it shows the game's own description of the spell.
- A short introduction with the addon's icon and version at the top.
- Live previews under each message box, in chat colours, showing exactly how the whisper and group messages will look as you type.
- A clearer explanation of `{spell}` and `{target}`, at the top of the Messages section.
- The options page and README explain where group messages go: party chat in a party, raid chat in a raid, instance chat in dungeon finder and battleground groups.
- The Profiles page shows the current profile's name on one line.

## 1.2.0

EmergencyAnnounce now announces two kinds of cooldown: protective cooldowns you cast on others, and your own defensive cooldowns.

- More protective cooldowns on others: druid Innervate and Rebirth, priest Fear Ward (and Power Infusion, off by default), warlock Soulstone.
- New: your own defensive cooldowns are announced to your group: warrior Last Stand and Shield Wall, druid Frenzied Regeneration. Barkskin, Retaliation, Divine Shield, Divine Protection, Templar's Bulwark, Ice Block, Evasion and Deterrence can be switched on. They have their own wording (`Used {spell}!`).
- A real options page: Esc > Options > AddOns > EmergencyAnnounce. `/ea` opens it.
- Profiles: share one setup across characters, or keep one per character.
- Every option can still be changed from chat. `/ea help` lists them, for example `/ea innervate on`. Spells are now turned on and off by name alone: `/ea loh on` replaces `/ea spell loh on`.
- Built on the Ace3 libraries.
- An icon in the addon list (the game's own Battle Shout icon).
- Settings from 1.1.0 are reset to the defaults once.

## 1.1.0

- Spells are matched by spell ID, so the addon works in every client language.
- Settings are saved and changed in game with `/ea`. Type `/ea help` for the list.
- Divine Intervention is announced too.
- Lay on Hands is now off by default: it's a big heal, but it doesn't change what the target should do. Turn it back on with `/ea spell loh on`.
- Optional Blessing of Sacrifice announcements (off by default).
- Message text uses `{spell}` and `{target}`.
- Whispers to players from other realms use their full name.

## 1.0

- First version: Blessing of Protection, Blessing of Freedom and Lay on Hands.
