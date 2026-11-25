# EmergencyAnnounce

A small WoW: Forever addon that announces two kinds of cooldown the moment they actually land:

- **Protective cooldowns on others:** it whispers the person and tells your party or raid. Blessing of Protection, Blessing of Freedom, Divine Intervention, Innervate, Rebirth, Fear Ward, Soulstone.
- **Your own defensive cooldowns:** it tells your party or raid. Last Stand, Shield Wall, Frenzied Regeneration, and more you can switch on.

## Protective cooldowns on others

Whispered to the person and announced to your group.

| Class | Spell | Option | Starts |
| --- | --- | --- | --- |
| Paladin | Blessing of Protection | `bop` | On |
| Paladin | Blessing of Freedom | `freedom` | On |
| Paladin | Divine Intervention | `di` | On |
| Paladin | Lay on Hands | `loh` | Off |
| Paladin | Blessing of Sacrifice | `sacrifice` | Off |
| Druid | Innervate | `innervate` | On |
| Druid | Rebirth | `rebirth` | On |
| Priest | Fear Ward | `fearward` | On |
| Priest | Power Infusion | `pi` | Off |
| Warlock | Soulstone | `soulstone` | On |

## Your own defensive cooldowns

Announced to your group (solo, nothing is sent).

| Class | Spell | Option | Starts |
| --- | --- | --- | --- |
| Warrior | Last Stand | `laststand` | On |
| Warrior | Shield Wall | `shieldwall` | On |
| Warrior | Retaliation | `retaliation` | Off |
| Druid | Frenzied Regeneration | `frenziedregen` | On |
| Druid | Barkskin | `barkskin` | Off |
| Paladin | Divine Shield | `divineshield` | Off |
| Paladin | Divine Protection | `divineprotection` | Off |
| Paladin | Templar's Bulwark | `bulwark` | Off |
| Mage | Ice Block | `iceblock` | Off |
| Rogue | Evasion | `evasion` | Off |
| Hunter | Deterrence | `deterrence` | Off |

You only see your own class's spells. Every rank of each spell is covered.

## Features

- **Only successful casts are announced**, for both kinds. Pressing the key repeatedly, being out of range or on cooldown, or being interrupted sends nothing.
- **No spam.** The same spell on the same person is announced at most once every 10 seconds (you can change this).
- **Whispers go to real players only**, never to you and never to NPCs. Only protective cooldowns on others are whispered.
- **Party, raid or instance chat** is picked for you. Solo, a protective cooldown on someone is only whispered, and your own defensive cooldowns aren't announced.
- **Separate wording** for protective cooldowns on others and for your own defensive cooldowns.
- **Works in any client language.** Spells are matched by spell ID.
- **Options page and profiles.** Esc > Options > AddOns > EmergencyAnnounce. Share one setup across characters or keep one per character.

## Commands

| Command | What it does |
| --- | --- |
| `/ea` | Open the options page |
| `/ea help` | List every option you can change from chat |
| `/ea whisper [on\|off]` | Whisper the person your protective cooldown lands on |
| `/ea group [on\|off]` | Tell your party or raid (both kinds) |
| `/ea <spell option> [on\|off]` | Turn a spell on or off, for example `/ea innervate on` or `/ea laststand off` |
| `/ea throttle <seconds>` | How long before the same spell on the same person is announced again |
| `/ea whispertext <text>` | Whisper wording for protective cooldowns on others. `{spell}` and `{target}` are filled in |
| `/ea grouptext <text>` | Group wording for protective cooldowns on others |
| `/ea selftext <text>` | Group wording for your own defensive cooldowns |
| `/ea test` | Preview the messages in your own chat |

Default wording:

| Message | Default |
| --- | --- |
| Protective cooldown on others, whisper | `{spell} on you!` |
| Protective cooldown on others, group | `{spell} on {target}` |
| Your own defensive cooldown, group | `Used {spell}!` |

## Limits

- WoW: Forever only (interface 16001).
- The game sometimes blocks addon chat messages. When that happens, EmergencyAnnounce prints a line in your own chat instead of sending.

## Building a release zip

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

This writes `dist\EmergencyAnnounce-<version>.zip`.

## Credits

- Built on [Ace3](https://github.com/WoWUIDev/Ace3) (AceAddon, AceEvent, AceConsole, AceDB, AceDBOptions, AceLocale, AceGUI, AceConfig), included in `Libs` under its own licence (`Libs/Ace3-LICENSE.txt`).
- Spell availability on WoW: Forever checked against [talentsforever.com](https://talentsforever.com) data, licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Licence

Copyright (C) 2026 Garreth Stonecrash. GPL-3.0-or-later. See [LICENSE](LICENSE).
