# EmergencyAnnounce

A small WoW: Forever addon that announces two kinds of cooldown the moment your cast succeeds:

- **Protective cooldowns on others:** it whispers the person and tells your party or raid. Blessing of Protection, Blessing of Freedom, Divine Intervention, Innervate, Rebirth, Fear Ward, Soulstone.
- **Your own defensive cooldowns:** it tells your party or raid. Last Stand, Shield Wall, Frenzied Regeneration, and more you can switch on.

## Install

1. Download `EmergencyAnnounce-<version>.zip` from the [Releases page](https://github.com/illepic/EmergencyAnnounce/releases/latest).
2. Extract it into `World of Warcraft\_forever_\Interface\AddOns`, so that you end up with `AddOns\EmergencyAnnounce\EmergencyAnnounce.toc`.
3. Restart the game, then type `/ea` to open the options.

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

Announced to your group. Not in a group, nothing is sent, since there's no group to tell.

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

You only see your own class's spells. Every rank of each spell counts.

## Features

- **Only successful casts are announced**, for both kinds. Pressing the key repeatedly, being out of range or on cooldown, or being interrupted sends nothing.
- **Whispers go to real players only**, never to you and never to NPCs. Only protective cooldowns on others are whispered.
- **Party, raid or instance chat** is picked for you, and in a raid you choose raid chat, raid warning, your own subgroup or nothing. Not in a group, a protective cooldown on someone is only whispered to them, and your own defensive cooldowns aren't announced.
- **Separate wording** for protective cooldowns on others and for your own defensive cooldowns.
- **Works in any client language.** Spells are matched by the game's own spell names.
- **Options page and profiles.** Esc > Options > AddOns > EmergencyAnnounce. Spell icons, the game's own spell descriptions on hover, and live previews of your messages in chat colours. Share one setup across characters or keep one per character.

## How a cast is confirmed

EmergencyAnnounce announces a spell once the game confirms your cast succeeded:

1. When you press the spell, the game reports the cast and who it's aimed at. EmergencyAnnounce notes it but sends nothing yet.
2. When the game confirms that same cast succeeded, EmergencyAnnounce announces it. The confirmation is matched to the cast by the game's own ID for that one cast, and it has to arrive within 5 seconds.

If the cast fails (out of range, on cooldown, out of mana, interrupted), no confirmation comes and nothing is sent.

What it doesn't check is what happens on the target afterwards. A successful cast means the spell went off, not that its effect stayed: a Rebirth still has to be accepted, and a blessing can be removed straight away. EmergencyAnnounce doesn't watch the target's buffs or read the combat log.

## Party, raid and instance groups

The group message goes to whichever chat fits the group you're in at that moment:

| You're in | Group message goes to |
| --- | --- |
| A party | Party chat |
| A raid | Your choice (see below); raid chat by default |
| A group the game made for you (dungeon finder, battleground) | Instance chat |
| Not in a group | No group message. A protective cooldown on someone, such as a stranger you save while questing, is only whispered to them. Your own defensive cooldowns aren't announced, since there's no group to tell. |

### In a raid

Choose where the group message goes under **Announce > In a raid** in the options, or with `/ea raid <choice>`:

| Choice | Command | Group message goes to |
| --- | --- | --- |
| Raid chat (default) | `/ea raid raid` | The whole raid |
| Raid warning | `/ea raid warning` | The big warning text in the middle of everyone's screen. Only the raid leader and assistants can send it, so anyone else's message goes to raid chat instead. |
| My subgroup only | `/ea raid subgroup` | Party chat, which in a raid reaches only your own five-person group |
| Don't announce | `/ea raid off` | Nothing; whispers are still sent |

In a raid, the whisper still reaches anyone in the raid, not just your own subgroup.

## Commands

| Command | What it does |
| --- | --- |
| `/ea` | Open the options page |
| `/ea help` | List every option you can change from chat |
| `/ea whisper [on\|off]` | Whisper the person you cast your protective cooldown on |
| `/ea group [on\|off]` | Tell your party or raid (both kinds) |
| `/ea raid <raid\|warning\|subgroup\|off>` | Where the group message goes in a raid |
| `/ea <spell option> [on\|off]` | Turn a spell on or off, for example `/ea innervate on` or `/ea laststand off` |
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

`{spell}` becomes a link showing the spell's name, with no rank. Hover or click it in chat to see the game's own tooltip for the exact rank you cast. Each message must contain `{spell}` and can be up to 150 characters, which leaves room for the link and the name within the game's chat limit.

## Limits

- WoW: Forever only (interface 16001).
- The game sometimes blocks addon chat messages. When that happens, EmergencyAnnounce prints a line in your own chat instead of sending.

## Building and releasing

Check the code with [luacheck](https://github.com/lunarmodules/luacheck) (settings in `.luacheckrc`; the bundled Ace3 libraries are skipped):

```powershell
luacheck .
```

Build a zip locally (for testing):

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

This writes `dist\EmergencyAnnounce-<version>.zip`.

To release a new version:

1. Add a `## X.Y.Z` section at the top of `CHANGELOG.md` and set `## Version: X.Y.Z` in `EmergencyAnnounce.toc`.
2. Commit and push.
3. Tag and push the tag:

   ```powershell
   git tag -a vX.Y.Z -m "EmergencyAnnounce X.Y.Z"
   git push origin vX.Y.Z
   ```

The [Release workflow](.github/workflows/release.yml) then builds the zip, publishes the GitHub release with that version's changelog section, and uploads the same zip and notes to CurseForge, marked with the newest WoW Forever game version. Tags ending in `-beta` or `-alpha` are published as beta or alpha. To publish an existing tag again, use **Actions > Release > Run workflow** and enter the tag.

## Credits

- Built on [Ace3](https://github.com/WoWUIDev/Ace3) (AceAddon, AceConsole, AceDB, AceDBOptions, AceLocale, AceGUI, AceConfig), included in `Libs` under its own licence (`Libs/Ace3-LICENSE.txt`).
- Spell availability on WoW: Forever checked against [talentsforever.com](https://talentsforever.com) data, licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Licence

Copyright (C) 2026 Garreth Stonecrash. GPL-3.0-or-later. See [LICENSE](LICENSE).
