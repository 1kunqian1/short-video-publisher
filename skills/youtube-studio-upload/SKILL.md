---
name: youtube-studio-upload
description: Upload a video to YouTube through YouTube Studio in the user's own logged-in Chrome (Chrome DevTools MCP). Confirms the right channel first (switching channels if needed), uploads the file, fills title, description, custom thumbnail, audience, tags, language, category, AI and paid-promotion disclosures, sets visibility to Public (or Schedule), and stops right before the Publish button so the user reviews and publishes. Use this skill whenever the user wants to upload, post or publish a YouTube Short or YouTube video from a file, put a video "on my channel", or fill in YouTube Studio for them, even if they don't say "Studio" or "browser". For posting the same Short to TikTok and Instagram too, use short-video-publish-orchestrator.
license: Proprietary. See LICENSE.md in the pack root
compatibility: Requires the Chrome DevTools MCP server and Google Chrome with a profile logged into the YouTube channel(s). Reads publish-config.yaml.
metadata:
  version: 1.0.0
  pack: short-video-publisher
  author: KelvinNextStop
---

# YouTube Studio Upload

Upload a video in **YouTube Studio** (studio.youtube.com), fill in everything, choose **Public**, and stop before **Publish**. The user reviews it in the dialog and clicks **Publish** themselves.

## Ground rules

- **Never click Publish** (or Save, or Schedule). Until the user does, the video sits as a **private draft** ("Saved as private"), so nothing goes public by accident.
- **Check the channel before uploading.** Studio remembers the last channel used, so it may be on the wrong one. A wrong-channel upload has to be deleted and redone.
- **Stop at verification gates.** If YouTube asks for verification, stop and tell the user (see step 4.3). Don't work around it.
- **Browser only.** Everything happens in YouTube Studio. If a step fails, report it to the user.

## Inputs

| Input | Source |
|---|---|
| Video | Path from the user or the orchestrator. Shorts: vertical, 180 s or shorter |
| Title, description, tags, settings | Metadata note (format: `short-video-publish-orchestrator/references/metadata-format.md`) |
| Thumbnail | 9:16 for Shorts, 16:9 for long videos. Must be **under 2 MB**: run `scripts/prepare_thumbnail.sh cover.png .tmp/thumbs` first |
| Channel | `youtube_channel` in the metadata, else `publish-config.yaml → youtube.default_channel` |

The thumbnail must be in a folder Chrome can read (inside the project), not `/tmp` or a system folder.

---

## Step 1: Open a tab in the right profile

If the orchestrator already gave you a tab, use it. Otherwise follow `references/browser-setup.md`: open a window in `browser.chrome_profile_directory`, connect with `list_pages`, use the new `about:blank` page. Don't use `new_page` (wrong profile).

## Step 2: Confirm the channel

1. `navigate_page` to `https://studio.youtube.com/`.
2. Read the current channel: `evaluate_script` with `() => ({ id: ytcfg.get('CHANNEL_ID'), name: document.querySelector('#entity-name')?.innerText?.trim() })`.
3. Compare `id` with the target channel's `channel_id` from the config.
4. **Wrong channel:** click the avatar (**Account**) → **Switch account** → click the entry whose text contains the target **handle** (entries look like "My Channel @mychannel 3 subscribers"). Match by handle because display names can repeat. The page reloads on that channel's dashboard.
5. Read `CHANNEL_ID` again. Continue only if it matches.

## Step 3: Upload the file

1. On the dashboard, click **Upload videos** (or **Create → Upload videos**).
2. `upload_file` on **Select files** with the absolute video path.
3. Wait for **Title (required)**. The dialog immediately shows "Saved as private" and a **Video link**.
    - Shorts: the link must be `https://youtube.com/shorts/{id}`. A `watch?v=` or `youtu.be` link means YouTube sees it as a long video: stop and tell the user (usually not vertical, or longer than 3 minutes).
    - Note the video ID.
4. The upload continues in the background ("Uploading 52%…"). Fill in the details meanwhile.

## Step 4: Details

All fields are inside the `ytcp-uploads-dialog` element. `references/youtube-studio-ui.md` has ready-made scripts for each step below.

1. **Title.** YouTube pre-fills the file name. `Cmd/Ctrl+A` does *not* select it in this box (typed text lands mid-title). Instead select the box's contents with a script (`Range.selectNodeContents` on `#title-textarea #textbox`), press **Backspace**, type the title. Check `innerText` equals the title.
2. **Description.** Click the box, type paragraph by paragraph, **Enter twice** between paragraphs.
    - After the hashtags, a **hashtag suggestion list** opens and covers part of the form. Don't press Enter (it picks a suggestion) or Escape. Close it with a **real click** (`click` tool, not a script) on the **title box**, then check that the title and description are unchanged.
3. **Thumbnail.** `upload_file` on **Upload file** with the prepared JPEG. Check that the thumbnail area now shows the file name and the real image (a screenshot is the easiest check).
    - 🛑 **If "One-time verification needed" appears** ("To create more custom thumbnails daily… complete a brief verification"): the channel has hit the limit for custom thumbnails without verification. Click **Cancel** and **stop the whole upload here**. Don't fill in the remaining fields or go on to Visibility. Bring the tab to the front and tell the user:
      > YouTube needs a one-time channel verification before it accepts a custom thumbnail. Please verify in **Studio → Settings → Channel → Feature eligibility**, then tell me to continue. The video is saved as a private draft; the title and description are filled in.

      When the user says it's done, continue from this step (click **Upload file** again). If the prompt still appears, stop again.
4. **Playlists:** skip unless the metadata names one.
5. **Audience:** **No, it's not made for kids** (unless the metadata or config says otherwise).
6. **Show advanced settings**, then:
    - **Paid promotion:** No (unless the metadata says Yes).
    - **AI use:** as in the metadata/config. YouTube requires an answer. These radios aren't standard `tp-yt-paper-radio-button`s, so click them by their `uid` from `take_snapshot`.
    - **Tags:** click the Tags box, type all tags comma-separated **with a comma after the last one**. Each comma turns the text into a chip. Check the chip count and that the counter is under 500.
    - **Video language:** open the dropdown, click the `tp-yt-paper-item` whose text is exactly the channel's language.
    - **Category:** open the dropdown (default *People & Blogs*), click the exact category.
    - **Comments:** leave **On** unless told otherwise. Leave the remaining defaults.
7. **Next.**

## Step 5: Video elements and checks

1. **Video elements:** nothing for Shorts (end screens and cards aren't available). For long videos, only what the metadata asks for. **Next.**
2. **Checks** (sometimes labelled **Initial check**): **don't wait**. The copyright check can take about 10 minutes, and **Next** works while it runs. Click **Next** right away; you'll report the progress at hand-over. If it already shows a problem, tell the user.

## Step 6: Visibility, then stop

1. Click **Public**. For a scheduled video, expand **Schedule** and set the date and time from the metadata instead.
2. Check: the `PUBLIC` radio has `aria-checked="true"` and the final button (`#done-button`) reads **Publish** (or **Schedule**).
3. **Stop. Don't click it.**

## Step 7: Hand over

Bring the tab to the front (`select_page` with `bringToFront: true`). Report:

- **Channel:** name and ID (confirmed in step 2)
- **Filled in:** title, description, tags, language, category, audience, paid promotion, AI use, comments
- **Thumbnail:** custom cover set
- **Checks:** done and still running (e.g. "Copyright: checking 44%, about 6 min left")
- **Link:** `youtube.com/shorts/{id}` (live once published)
- **Next step:** review, click **Publish**. If the user doesn't, it stays a private draft.

**After the user publishes:** open `https://studio.youtube.com/video/{id}/edit` and check that it's **Public**, that the thumbnail is the real cover (image URL `sddefault.jpg?v=…`, not an auto-frame like `sd2.jpg`), and that a Short appears under **Content → Shorts**. Report anything that's off to the user. Delete the temporary thumbnail.

---

## References

- `references/youtube-studio-ui.md`: scripts and selectors for every step, and how to recognise each dialog
- `references/troubleshooting.md`: known problems and fixes
- `references/browser-setup.md`: profile, MCP connection, Allow prompt

## Tested scope (v1.0.0)

Tested end to end on a live English channel with a 1080×1920, 101 s Short: channel check, upload, every Details field, custom thumbnail (after verification), the verification-prompt stop, Visibility = Public. Not yet tested: switching to a second channel inside this skill (the switch itself works), long videos with Schedule.
