# Changelog

## 1.0.0 (2026-11-09)

First release.

### Skills

- `short-video-publish-orchestrator`: one session, three tabs, all uploads started first, unified hand-over report
- `youtube-studio-upload`: channel check and switch by handle, Shorts link check, title clearing, hashtag pop-up handling, custom thumbnail (JPEG under 2 MB), stop at the "One-time verification needed" prompt, advanced settings, no waiting for the copyright check, Public selected, stop before Publish
- `tiktok-studio-upload`: description clearing, exact-match hashtag conversion, 3:4 cover, settings, Music copyright check switched on, stop before Post
- `instagram-reels-upload`: Instagram-only "Post to", caption with line breaks, custom 9:16 cover, copyright check, stop before Share

### Included

- `publish-config.yaml` example and two presets (single channel, bilingual two channels)
- Metadata note template and a filled-in real example
- Sample session from start to hand-over
- macOS helpers: open tabs in a Chrome profile, auto-click "Allow remote debugging?", prepare thumbnails
- Test prompts (`evals/evals.json`) for every skill

### Tested on

- macOS, Google Chrome, Chrome DevTools MCP
- One English YouTube channel (plus channel switching between two channels), one TikTok account, one Instagram professional account via Meta Business Suite
- 1080×1920, 101-second vertical Short
