# EmergencyAnnounce

A small WoW: Forever addon for paladins. When one of your emergency spells actually lands (Blessing of Protection, Blessing of Freedom, Divine Intervention, and optionally Lay on Hands or Blessing of Sacrifice), it whispers the person and tells your party or raid, so they know what just happened.

## Spells

| Spell | Key | Starts |
| --- | --- | --- |
| Blessing of Protection | `bop` | On |
| Blessing of Freedom | `freedom` | On |
| Divine Intervention | `di` | On |
| Lay on Hands | `loh` | Off |
| Blessing of Sacrifice | `sacrifice` | Off |

Turn any of them on or off with `/ea spell <key>`, for example `/ea spell sacrifice on`. Every rank of each spell is covered.

## Features

- **Only successful casts are announced.** Pressing the key repeatedly, being out of range or on cooldown, or being interrupted sends nothing.
- **No spam.** The same spell on the same person is announced at most once every 10 seconds (you can change this).
- **Whispers go to real players only**, never to you and never to NPCs.
- **Party, raid or instance chat** is picked for you. Solo, only the whisper is sent.
- **Works in any client language.** Spells are matched by spell ID.

## Commands

| Command | What it does |
| --- | --- |
| `/ea` | Show your settings |
| `/ea whisper [on\|off]` | Whisper the person you protect |
| `/ea group [on\|off]` | Tell your party or raid |
| `/ea spell <key> [on\|off]` | Choose spells: `bop`, `freedom`, `di`, `loh`, `sacrifice` |
| `/ea throttle <seconds>` | How long before the same spell on the same person is announced again |
| `/ea whispertext <text>` | Whisper wording. `{spell}` and `{target}` are filled in |
| `/ea grouptext <text>` | Group wording |
| `/ea test` | Preview both messages in your own chat |
| `/ea reset` | Back to the defaults |

Defaults: whisper `{spell} on you!`, group `{spell} on {target}`.

## Limits

- WoW: Forever only (interface 16001).
- The game sometimes blocks addon chat messages. When that happens, EmergencyAnnounce prints a line in your own chat instead of sending.

## Building a release zip

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

This writes `dist\EmergencyAnnounce-<version>.zip`. Upload that zip to CurseForge.

## Licence

Copyright (C) 2026 Garreth Stonecrash. GPL-3.0-or-later. See [LICENSE](LICENSE).
