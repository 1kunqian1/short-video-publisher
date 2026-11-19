---
name: tiktok-studio-upload
description: Fill in a TikTok post in TikTok Studio (tiktok.com/tiktokstudio) in the user's own logged-in Chrome (Chrome DevTools MCP). Uploads the video, replaces the auto-filled description with the caption, turns every hashtag into a real clickable TikTok hashtag, uploads a custom 3:4 cover, sets privacy, comments and AI disclosure, switches on the music copyright check, waits for both checks, and stops right before the Post button so the user reviews and posts. Use this skill whenever the user wants to upload, post or publish a video, short or clip to TikTok, or says "put this on TikTok", even if they don't mention TikTok Studio or a browser. For posting the same video to YouTube and Instagram too, use short-video-publish-orchestrator.
license: Proprietary. See LICENSE.md in the pack root
compatibility: Requires the Chrome DevTools MCP server and Google Chrome with a profile logged into TikTok. Reads publish-config.yaml.
metadata:
  version: 1.0.0
  pack: short-video-publisher
  author: KelvinNextStop
---

# TikTok Studio Upload

Fill in a post in **TikTok Studio**, make the hashtags real, set the cover and settings, and stop with **Post** visible. The user reviews and clicks **Post**.

## Ground rules

- **Never click Post** (or Save draft, unless the user asks). Posting is the user's decision.
- **Check the account.** The upload page shows the account's avatar and name. If it isn't `tiktok.handle` from the config, or you see a login page, stop and ask the user to log in to the right account **in the configured Chrome profile**.
- **Browser only.** Everything happens in TikTok Studio. If a step fails, report it to the user.
- **Field problems don't stop you.** A hashtag with no exact match is left as plain text and reported. Keep going.

## Inputs

| Input | Source |
|---|---|
| Video | From the user or orchestrator. TikTok accepts up to 30 GB / 60 min; no conversion needed |
| Caption | `## Caption` in the metadata note (shared with YouTube and Instagram) |
| Settings | `## TikTok → Settings` in the metadata note, else `publish-config.yaml → defaults` |
| Cover | **3:4** image. The cover editor's frame and the profile grid are both 3:4, so it fills with no cropping. No 3:4 cover → keep TikTok's auto frame and say so in the report |

Files must be in a folder Chrome can read (inside the project).

---

## Step 1: Open the upload page

Use the tab the orchestrator gave you, or open one in the configured profile (`references/browser-setup.md`; don't use `new_page`). Then:

```
https://www.tiktok.com/tiktokstudio/upload?from=creator_center&lang=en
```

Wait for **Select video** and check the avatar/name is the configured account. A banner "A video you were editing wasn't saved. Continue editing?" may appear: ignore it, don't click Discard or Continue.

## Step 2: Upload the video

`upload_file` on **Select video** with the absolute path. Wait until the page says **Uploaded** with the file size. An onboarding pop-up ("Preview your video on your phone") may appear: click **Got it**.

## Step 3: Description

TikTok pre-fills the description with the file name.

1. **Clear it.** `Cmd/Ctrl+A` does *not* select text in this box. Select the editor's contents with a script (`[contenteditable=true]`, `Range.selectNodeContents`), then press **Backspace**. Check that it's empty. (Script in `references/tiktok-studio-ui.md`.)
2. **Type the caption paragraphs.** **Enter twice** between paragraphs and twice more before the hashtags.

## Step 4: Hashtags, one at a time

A hashtag typed as text stays plain text. It only becomes a real (clickable, searchable) hashtag when **picked from TikTok's suggestion list**.

For each tag:

1. Type it with no trailing space, e.g. `#aithumbnail`.
2. Wait ~2 seconds for the list. Read the **highlighted** item (`.hashtag-suggestion-item.focused`).
3. If it's **exactly** the tag: press **Enter**. TikTok converts it and adds a space.
4. If it isn't exact: don't press Enter (you'd get a different tag). Type a space instead, and report "left as plain text".

A script `click()` on a suggestion doesn't work; the Enter key does. At the end, the editor's `.mention` elements should list every converted hashtag.

## Step 5: Cover

1. Click **Edit cover** (below the description).
2. In the window that opens, `upload_file` on **Upload cover image** with the 3:4 image.
3. Check it fills the frame and appears in the profile preview, then click **Save**. (The preview is labelled "(4:3)" but the tiles are portrait 3:4. Use the 3:4 image.)

## Step 6: Settings

- **When to post:** **Now**, unless the metadata gives a schedule (then **Schedule** + time).
- **Who can see this post:** **Everyone** (or as the metadata says).
- Click **Show more**, then check: **Comment** on · **Disclose post content** off (unless it's a paid promotion) · **AI-generated content** as the metadata/config says · **Audience control** off.
- Duet and Stitch aren't offered for videos over 60 seconds. That's normal.

## Step 7: Checks

1. **Switch on Music copyright check.** It starts **off**, and while off it only shows its description and never runs. Find the switch whose label starts with "Music copyright check" (in **Checks**, after **Show more**), click it, confirm `aria-checked` is `true`. (Controlled by `tiktok.music_copyright_check`, default on.)
2. **Content check lite** is usually on already; turn it on if not.
3. Wait until **both** say **"No issues found"**. Music usually finishes in seconds; the content check can take a few minutes. In the orchestrator, fill other tabs meanwhile. If either finds a problem, tell the user.

## Step 8: Hand over

Bring the tab to the front (`select_page`, `bringToFront: true`). Report:

- account, caption, **which hashtags became real** (and any left as text), cover, settings, both check results
- how to check the cover without changing it: **Edit cover** → **Cancel**
- next step: click **Post** (or **Save draft** to keep it for later)

After the user posts: get the link from **TikTok Studio → Posts** (or the profile) and record it in the metadata note.

---

## References

- `references/tiktok-studio-ui.md`: scripts for clearing the description, reading suggestions, listing hashtags, the check switches
- `references/browser-setup.md`: profile, MCP connection, Allow prompt

## Tested scope (v1.0.0)

Tested twice on a live account with a 1080×1920, 101 s video, up to the Post button: description clearing, 4/4 hashtags converted, 3:4 cover, settings, both checks (with Music copyright check switched on manually). Not yet tested: Schedule, Save draft round-trip, landscape videos.
