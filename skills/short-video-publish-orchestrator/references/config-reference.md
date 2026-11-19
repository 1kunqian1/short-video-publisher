# `publish-config.yaml` Reference

One config file holds everything account-specific, so the skills themselves never contain anyone's IDs. All four skills read the same file.

**Where it lives (first match wins):** a path the user gives → `publish-config.yaml` in the project root → `~/.short-video-publisher/publish-config.yaml`.

---

## `browser`

| Field | Example | Where to find it |
|---|---|---|
| `chrome_profile_directory` | `Profile 3` | `chrome://version` → **Profile Path**, last folder. See `browser-setup.md` §2 |
| `os` | `macos` | `macos`, `windows` or `linux`. Decides which helper commands the agent uses |

## `youtube`

| Field | Example | Where to find it |
|---|---|---|
| `default_channel` | `main` | The key of the channel to use when the metadata doesn't name one |
| `channels[].key` | `main` | Your own short name, used in metadata notes (`youtube_channel: main`) |
| `channels[].name` | `My Channel` | Channel name as shown in YouTube Studio |
| `channels[].channel_id` | `UCxxxxxxxxxxxxxxxxxxxxxx` | YouTube Studio URL: `studio.youtube.com/channel/UC...`. Starts with `UC`, 24 characters |
| `channels[].handle` | `@mychannel` | Studio → Customization → Basic info → Handle. Used to pick the channel in **Switch account**, because two channels can share a display name |
| `channels[].language` | `English` | Exact name in Studio's **Video language** list |
| `channels[].default_category` | `Science & Technology` | Exact name in Studio's **Category** list |

Several channels under one Google account (e.g. a main channel plus a brand account) are fine. The skill switches between them with **Account → Switch account**.

## `tiktok`

| Field | Example | Notes |
|---|---|---|
| `handle` | `@myhandle` | Shown on the upload page next to the avatar; the skill checks it before filling in |
| `music_copyright_check` | `true` | Turn on TikTok's Music copyright check on every upload (it starts off) |

## `instagram`

| Field | Example | Where to find it |
|---|---|---|
| `username` | `myhandle` | Your Instagram username, no `@` |
| `business_suite.asset_id` | `1234567890123456` | Open Meta Business Suite with your Instagram/Page selected; the URL contains `asset_id=…` |
| `business_suite.business_id` | `1234567890123456` | Same URL, `business_id=…` |
| `post_to` | `instagram_only` | `instagram_only` unticks the connected Facebook Page in "Post to"; `instagram_and_facebook` keeps both |

The skill builds the Reel composer link from these IDs:
`https://business.facebook.com/latest/reels_composer/?asset_id={asset_id}&business_id={business_id}&locale=en_US`

## `defaults`

Used when a metadata note doesn't say otherwise.

| Field | Default | Meaning |
|---|---|---|
| `made_for_kids` | `false` | YouTube audience question |
| `paid_promotion` | `false` | YouTube paid promotion, Instagram paid partnership, TikTok "Disclose post content" |
| `ai_disclosure` | `false` | YouTube "AI use", TikTok "AI-generated content", Instagram AI label. **Set `true` (or set it per video) when the video shows realistic AI-generated people, scenes or voices.** The platforms require it |
| `comments` | `true` | Allow comments everywhere |

## `assets` (optional)

| Field | Example | Meaning |
|---|---|---|
| `video_patterns` | `["**/final*/*.mp4", "**/*final*.mp4"]` | Where to look for the finished video when the user doesn't give a path |
| `cover_patterns.9x16` | `["**/thumbnail/final/*9x16*.png"]` | Where to look for the 9:16 cover |
| `cover_patterns.3x4` | `["**/thumbnail/final/*3x4*.png"]` | Where to look for the 3:4 cover |
| `temp_dir` | `.tmp/thumbs` | Where converted thumbnails go. **Must be readable by Chrome**, so keep it inside the project folder. The browser tool may refuse files outside allowed folders |
