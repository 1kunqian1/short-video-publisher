---
name: short-video-publish-orchestrator
description: Cross-post one finished vertical short video to YouTube Shorts, TikTok and Instagram Reels in a single run, through the user's own logged-in Chrome (Chrome DevTools MCP). Gathers the video, covers and captions, checks each account, starts all three uploads in parallel tabs, fills titles, captions, real hashtags, custom covers and settings, then stops right before every final Publish / Post / Share button so the user reviews and publishes. Use this skill whenever the user wants to publish, upload, post, cross-post or "send out" a short, reel, TikTok or vertical video to more than one platform, or says things like "upload this to social media", "post it everywhere", "publish my short", even if they don't list the platforms. For a single platform, use youtube-studio-upload, tiktok-studio-upload or instagram-reels-upload instead.
license: Proprietary. See LICENSE.md in the pack root
compatibility: Requires the Chrome DevTools MCP server and Google Chrome with one profile logged into YouTube, TikTok and Meta Business Suite. Bundled helper scripts are macOS; manual equivalents for Windows/Linux are in references/browser-setup.md.
metadata:
  version: 1.0.0
  pack: short-video-publisher
  author: KelvinNextStop
---

# Short Video Publish Orchestrator

Publish one vertical short video to **YouTube Shorts, TikTok and Instagram Reels** in one coordinated browser session. You do all the form-filling; the user clicks the three final buttons.

This skill coordinates three platform skills that live next to it:

- `youtube-studio-upload`: YouTube Studio
- `tiktok-studio-upload`: TikTok Studio
- `instagram-reels-upload`: Instagram Reels via Meta Business Suite

Read each platform's `SKILL.md` when you reach its part. This file only covers the order, the shared preparation and the final report.

---

## The rules that make this safe

These rules exist because the user is trusting you with their public accounts. Keep to them even when it would be faster not to.

1. **Never click the final button.** Stop with **Publish** (YouTube), **Post** (TikTok) and **Share** (Instagram) visible and unclicked. Posting is the user's decision, and an unreviewed public post can't be taken back cleanly.
2. **Check the account before uploading.** Read the channel or account on each page and compare it with `publish-config.yaml`. An upload to the wrong account means deleting it and starting over, and might be seen by the wrong audience.
3. **Stop at verification and permission gates.** If a platform asks for phone verification, a login, a CAPTCHA, or a "one-time verification", stop that platform and tell the user exactly what it asked. Don't work around the gate (e.g. by injecting files into hidden inputs). These gates are the platform's way of confirming the person, and only the user can satisfy them.
4. **Browser only.** Everything happens in the user's Chrome, on each platform's own upload page. If a step fails, report it to the user.
5. **One session, one browser connection.** Do all three platforms yourself, switching tabs. Don't hand platforms to parallel sub-agents: they share one Chrome DevTools connection, and `select_page` is global, so parallel agents would keep stealing each other's tab mid-typing.
6. **Field problems don't stop the run.** A hashtag that won't resolve, a caption that's too long, a missing optional setting: skip it, keep going, and list it in the final report. Only account, login and verification problems stop a platform.

---

## Step 0: Load the configuration

Look for `publish-config.yaml` in this order:

1. the path the user gave
2. the current project root
3. `~/.short-video-publisher/publish-config.yaml`

If none exists, offer to create one from `assets/publish-config.example.yaml` (or a preset in `assets/presets/`) and ask only for what's missing: Chrome profile, YouTube channel ID and handle, TikTok handle, Instagram username and the two Business Suite IDs. `references/config-reference.md` explains every field and where to find each value.

---

## Step 1: Gather and check the inputs (no browser yet)

| Input | Where it comes from |
|---|---|
| **Video** | The path the user gave. Otherwise look for a file named like `final`, `export`, or set in `publish-config.yaml → assets.video_patterns`. If several candidates exist and you can't tell which is final, **ask**. Raw footage and rough cuts are not finals |
| **Metadata** | A metadata note in the format of `assets/metadata-template.md` (see `references/metadata-format.md`). If there's none, write one with the user: a YouTube title, one caption shared by all three platforms, hashtags, YouTube tags, settings |
| **Covers** | 9:16 for YouTube and Instagram, 3:4 for TikTok. Missing a cover isn't fatal: each platform skill explains its fallback |

Check the video before opening anything:

```bash
# macOS
mdls -name kMDItemDurationSeconds -name kMDItemPixelWidth -name kMDItemPixelHeight "video.mp4"
# any OS with ffmpeg
ffprobe -v error -select_streams v:0 -show_entries stream=width,height:format=duration -of csv=p=0 "video.mp4"
```

A Short must be **vertical** and **180 seconds or shorter**. Otherwise YouTube treats it as a long video and the Shorts settings don't apply. If it doesn't fit, stop and tell the user.

Prepare the YouTube cover now: YouTube rejects thumbnails over **2 MB**, and designed PNG covers are often 3–4 MB.

```bash
scripts/prepare_thumbnail.sh "cover_9x16.png" ".tmp/thumbs"   # writes a same-size JPEG under 2 MB
```

Note any unfinished items in the metadata (e.g. "needs review" checkboxes). If the user asked you to publish directly, don't stop for them; list them in the final report.

---

## Step 2: Open three tabs in the right Chrome profile

Follow `references/browser-setup.md`. In short:

1. Open a new window in the **configured profile** (`scripts/open_profile_tabs.sh "{profile}" 3` on macOS). Don't use the MCP `new_page` tool: it opens in Chrome's default profile, which is usually logged into different accounts.
2. Connect the Chrome DevTools MCP (`list_pages`). On macOS, `scripts/allow_remote_debugging.applescript` clicks Chrome's "Allow remote debugging?" prompt for you; start it **before** `list_pages`.
3. From `list_pages`, note the three new `about:blank` page IDs and assign them: **YouTube**, **TikTok**, **Instagram**.

---

## Step 3: Start all three uploads first

Uploads take the longest, so start all three before filling anything:

1. **YouTube tab:** `youtube-studio-upload` steps 2–3: check the channel (switch if needed), then Upload videos → Select files. Confirm the link is `youtube.com/shorts/...`.
2. **TikTok tab:** `tiktok-studio-upload` steps 1–2: open the upload page, select the video.
3. **Instagram tab:** `instagram-reels-upload` steps 1–3: open the Reel composer, set "Post to" to Instagram only, Add Video.

---

## Step 4: Fill the three tabs in turn

While one tab is busy (processing, uploading, checking), work in another. A typical rhythm:

1. **YouTube:** title, description, cover, audience, advanced settings, then Next → Next to Visibility. **Don't wait for the copyright check**: Next is clickable while it runs. Select **Public** and stop.
2. **TikTok:** wait for "Uploaded", then clear the pre-filled description, type the caption, pick each hashtag from the suggestion list, upload the 3:4 cover, check settings, **switch on Music copyright check**.
3. **Instagram:** caption, upload the cover image, wait for "safe to publish", Next, Public / Share now.
4. **Back to TikTok:** wait until both checks say "No issues found".

**Before switching tabs, close any open suggestion list.** All three platforms open hashtag suggestions while you type. If you leave one open and come back, a stray Enter picks the wrong tag. Each platform skill explains how to close its list safely.

---

## Step 5: Final checks and hand-over

Re-check each tab, because the user may have clicked around while you worked:

- **YouTube:** still on Visibility = Public, final button reads **Publish**. Read the copyright check progress.
- **TikTok:** both checks "No issues found", **Post** visible.
- **Instagram:** on the Share step, Public, **Share** visible.

Bring the TikTok tab to the front last (`select_page` with `bringToFront: true`), since it's usually the one the user reviews first. Then report using this structure:

```markdown
## Ready to publish: {video title}

| Platform | Status | Your move |
|---|---|---|
| TikTok | {filled in; checks result} | Review, click **Post** |
| Instagram | {filled in; "safe to publish"} | Review, click **Share** |
| YouTube | {filled in; Public; cover set; copyright check X%} | Review, click **Publish** |

**Needs your attention**
- {skipped or changed fields, e.g. "TikTok: #xyz had no exact match, left as plain text"}
- {platform gates, e.g. "YouTube asked for one-time verification, stopped before the thumbnail"}
- {unfinished metadata items}

**Links:** YouTube {shorts link}. TikTok and Instagram links exist only after you post.
```

After the user says they've published: collect the three public links (YouTube Studio, TikTok Studio → Posts, the Instagram profile) and record them in the metadata note. Delete any temporary files you made (e.g. `.tmp/thumbs/`).

---

## When something goes wrong

| Situation | What to do |
|---|---|
| A page shows a login screen | Stop that platform. Ask the user to log in **in the configured Chrome profile**, then continue |
| Wrong account and switching fails | Stop that platform, report what you saw. Don't upload |
| Verification / CAPTCHA / "confirm it's you" | Stop that platform at that step, tell the user exactly what was asked. Continue only when the user says it's done |
| One platform fails | Finish the other two, report the failure with the step and the message shown |
| `list_pages` hangs | The "Allow remote debugging?" prompt wasn't clicked. Ask the user to click **Allow** in Chrome, or restart the helper and retry |
| UI looks different from the skill | Read the page (`take_snapshot`), match by visible labels and purpose. If you can't find a safe equivalent, stop and ask |

---

## Reference files

- `references/browser-setup.md`: open the right profile, connect the MCP, the "Allow" prompt, Windows/Linux equivalents
- `references/metadata-format.md`: the metadata note format and how each platform uses each field
- `references/config-reference.md`: every `publish-config.yaml` field and where to find the IDs
- `assets/publish-config.example.yaml`, `assets/presets/`: configs to copy
- `assets/metadata-template.md`: blank metadata note
- `examples/example-metadata.md`: a filled-in note for a real Short
- `examples/example-session.md`: a full sample run, start to hand-over

## Tested scope (v1.0.0)

Tested end to end on live accounts with a 1080×1920, 101-second Short. YouTube, TikTok and Instagram were each tested separately up to the final button. Running all three tabs together in one session (Steps 3–4) follows the same pattern but hasn't been timed end to end yet.
