# Example Session: One Short to Three Platforms

A condensed run based on a real test. It shows the order of work, what the agent checks, and the hand-over at the end.

---

## The request

> **User:** Upload `shorts/thumbnail-tips/final/thumbnail-tips-final.mp4` to social media. Metadata is in `shorts/thumbnail-tips/upload-metadata.md`.

## Step 0–1: Config and inputs

```text
Loaded publish-config.yaml (project root)
  Chrome profile: Profile 3 · YouTube channel: main (@mychannel) · TikTok @myhandle · Instagram myhandle

Video: thumbnail-tips-final.mp4: 1080×1920, 101.5 s → valid Short ✅
Metadata: status ready · 1 open item (AI label: left at No)
Covers: thumbnail_9x16.png (3.7 MB) · thumbnail_3x4.png
  → scripts/prepare_thumbnail.sh → .tmp/thumbs/thumbnail_9x16.jpg (0.8 MB) for YouTube
```

The open metadata item isn't a blocker because the user asked to publish directly. It goes into the final report.

## Step 2: Browser

```text
scripts/open_profile_tabs.sh "Profile 3" 3
osascript scripts/allow_remote_debugging.applescript &   (running ✅)
list_pages → pages 9, 10, 18 are about:blank → TikTok=9, Instagram=10, YouTube=18
```

## Step 3: Start all uploads

```text
[YouTube 18]   studio.youtube.com → CHANNEL_ID = UCxxxx… = config "main" ✅
               Upload videos → Select files → link youtube.com/shorts/pc20hXNCxQg ✅ (Short)
[TikTok 9]     upload page shows Select video + @myhandle avatar ✅ → Select video
[Instagram 10] Reel composer → Post to: untick the Facebook option (by icon) → "Instagram myhandle" ✅ → Add Video
```

## Step 4: Fill in turn

```text
[YouTube]   Title: cleared by script + Backspace (Cmd+A doesn't select here) → typed ✅
            Description typed → hashtag pop-up opened → closed with a real click on the title box ✅
            Upload file → .tmp/thumbs/thumbnail_9x16.jpg → cover shown ✅
            Not for kids · Paid promotion No · AI use No · 8 tags as chips · English · Science & Technology
            Next → Next (copyright check still running, not waiting) → Visibility: Public ✅, button reads "Publish". STOP

[TikTok]    Uploaded (48.24 MB) → description pre-filled with file name → cleared → caption typed
            #aithumbnail → suggestion highlighted is exact → Enter ✅ (×4 hashtags, all real)
            Edit cover → Upload cover image → 3:4 fills frame → Save ✅
            Show more → Comment on, Disclose off, AI-generated off
            Music copyright check: OFF by default → switched on ✅

[Instagram] Caption typed → Escape → Upload image tab → Upload image link → "Change image" ✅
            "Your video is safe to publish!" → (waited for thumbnail to finish uploading) → Next
            Share step: Public (greyed, already set) · Share now. STOP

[TikTok]    Music copyright check: No issues found · Content check lite: No issues found ✅. STOP
```

## Step 5: Hand-over (what the user sees)

```markdown
## Ready to publish: 2 AI thumbnail tips to stop retrying

| Platform | Status | Your move |
|---|---|---|
| TikTok | Filled in, 4/4 hashtags real, 3:4 cover, both checks "No issues found" | Review, click **Post** |
| Instagram | Instagram only, caption, custom cover, "safe to publish", Public / Share now | Review, click **Share** |
| YouTube | @mychannel, Public selected, custom cover, 8 tags; copyright check 44% (about 6 min left) | Review, click **Publish** |

**Needs your attention**
- AI disclosure is Off on all three. The video shows AI-made images of your face; switch it on before posting if you want the label.

**Links:** YouTube https://youtube.com/shorts/pc20hXNCxQg (live after you click Publish).
TikTok and Instagram links exist only after you post.
```

## After the user publishes

```text
User: "Posted all three."
→ YouTube Studio: Public ✅, cover sddefault.jpg (real cover) ✅, under Content → Shorts ✅
→ TikTok Studio → Posts: link copied · Instagram profile: permalink copied
→ Links written into the metadata note's "Published" section
→ .tmp/thumbs/ deleted
```

---

## Variation: a platform asks for verification

```text
[YouTube] Upload file → dialog "One-time verification needed: to create more custom thumbnails daily…"
          → Cancel. STOP YouTube here (no other fields filled after this point)
```

The hand-over then says:

> **YouTube stopped at the thumbnail.** YouTube needs a one-time channel verification before it accepts custom thumbnails. Please verify in **Studio → Settings → Channel → Feature eligibility**, then tell me to continue. The video is saved as a private draft; title and description are already filled in.
