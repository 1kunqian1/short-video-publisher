---
name: instagram-reels-upload
description: Fill in an Instagram Reel in Meta Business Suite (business.facebook.com) in the user's own logged-in Chrome (Chrome DevTools MCP). Sets "Post to" to the Instagram account only, uploads the video, types the caption with its line breaks, uploads a custom cover image, waits for the copyright check, and stops on the Share step with Public and Share now selected, right before the Share button, so the user reviews and shares. Use this skill whenever the user wants to post, upload or publish a Reel or vertical video to Instagram, cross-post a short to Instagram, or says "put this on IG", even if they don't mention Business Suite. For posting the same video to YouTube and TikTok too, use short-video-publish-orchestrator.
license: Proprietary. See LICENSE.md in the pack root
compatibility: Requires the Chrome DevTools MCP server, Google Chrome with a profile logged into Facebook/Meta Business Suite, and an Instagram professional account connected to a Business Suite portfolio. Reads publish-config.yaml.
metadata:
  version: 1.0.0
  pack: short-video-publisher
  author: KelvinNextStop
---

# Instagram Reels Upload (Meta Business Suite)

Fill in an Instagram Reel in **Meta Business Suite's Reel composer**, then stop on the **Share** step. The user reviews and clicks **Share**.

Business Suite is used instead of instagram.com because it supports a **custom cover image** and scheduling from a desktop browser.

## Ground rules

- **Never click Share** (or Schedule). An unpublished Reel has no link and no draft option here, so **keep the tab open** until the user shares.
- **Post to Instagram only** (unless `instagram.post_to` is `instagram_and_facebook`). Business Suite pre-selects both the Instagram account and the connected Facebook Page.
- **Check the account.** The composer shows the account name. If Business Suite shows a login page or a different portfolio, stop and ask the user to log in **in the configured Chrome profile**.
- **Browser only.** Everything happens in Business Suite. If a step fails, report it to the user.

## Inputs

| Input | Source |
|---|---|
| Video | From the user or orchestrator. Uploaded as-is; Instagram re-processes it |
| Caption | `## Caption` in the metadata note |
| Cover | **9:16** image (same as the YouTube Shorts cover) |
| Settings | `## Instagram → Settings`, else `publish-config.yaml → defaults` |
| Composer IDs | `instagram.business_suite.asset_id` and `business_id` from the config |

Files must be in a folder Chrome can read (inside the project).

---

## Step 1: Open the Reel composer

Use the tab the orchestrator gave you, or open one in the configured profile (`references/browser-setup.md`; don't use `new_page`). Navigate to:

```
https://business.facebook.com/latest/reels_composer/?asset_id={asset_id}&business_id={business_id}&locale=en_US
```

The page should show **Create reel** and the account name. Banners (terms updates, "All videos you post on Facebook are now reels") can be ignored.

## Step 2: Post to: Instagram only

1. Click the **Post to** dropdown. The list shows **two options with the same name**: one is the Facebook Page, one is the Instagram account. They differ only by their **icon**. Check which is which with a script (`references/business-suite-ui.md` §2); the Facebook one is usually first.
2. Click the **Facebook option itself** to untick it. Clicking the dropdown box again only closes the list.
3. Close the list. The box should now read **Instagram {username}** only.
4. Don't tick **Save preference** in that list unless the user asks; it changes their default for every future post.

## Step 3: Add the video

`upload_file` on **Add Video** with the absolute path. Wait for **100%** and the resolution (e.g. **1080 x 1920**). The video-specific sections (**Thumbnail**, the copyright check) appear once it's in.

## Step 4: Caption

1. Click the caption box and type the caption. **Enter twice** between paragraphs.
2. After the hashtags, press **Escape** to close the hashtag suggestions.
3. If a suggestion list is still open, **don't press Enter** (it picks a suggestion). Go straight to step 5: clicking the thumbnail tab closes the list and leaves the caption as typed.

The preview on the right shows the paragraphs run together. That's only the preview; the published Reel keeps the blank lines.

## Step 5: Cover

1. Under **Thumbnail**, click the **Upload image** tab.
2. `upload_file` on the **Upload image** *link* that appears under it (not the tab itself).
3. Check that the link now reads **Change image** (and the image shows a blue check mark).

## Step 6: Copyright check, then Next

1. Wait for **"Your video is safe to publish!"** ("No copyright issues were found."). If it reports a problem, stop and tell the user.
2. Click **Next**. If it's greyed out with "Please wait for the thumbnail to upload.", wait a few seconds and try again.

## Step 7: Share step, then stop

1. **Who can see this?** **Public** should be selected. Sometimes nothing is selected and you have to click it; sometimes it's already checked and greyed out, which is fine.
2. **Scheduling options:** leave **Share now**, unless the metadata gives a time (then **Schedule** and set it).
3. **AI label / paid partnership:** if the metadata says On, tell the user to check those before sharing (or set them in the Instagram app afterwards).
4. **Stop. Don't click Share.**

## Step 8: Hand over

Bring the tab to the front (`select_page`, `bringToFront: true`). Report:

- account (Instagram only), video, caption, cover, visibility, copyright check
- how to check the cover: click **Back**, look at **Thumbnail → Upload image** (the preview only plays the video)
- next step: click **Share** (bottom right), or **Schedule**. **Keep this tab open until then**; there's no draft to come back to.

After the user shares: open the Instagram profile, copy the Reel's permalink, record it in the metadata note.

---

## References

- `references/business-suite-ui.md`: scripts for telling the two "Post to" options apart, checking upload/cover/copyright status, the Share step
- `references/browser-setup.md`: profile, MCP connection, Allow prompt

## Tested scope (v1.0.0)

Tested twice on a live account with a 1080×1920, 101 s video, up to the Share button: Instagram-only selection, upload, caption with line breaks (confirmed after a real post), 9:16 custom cover (confirmed as the real cover after posting), copyright check, Share step. Not yet tested: Schedule, posting to Facebook too.
