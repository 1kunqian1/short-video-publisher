# Short Video Publisher: Agent Skills Pack

**Publish one vertical short video to YouTube Shorts, TikTok and Instagram Reels from your own browser, with an AI agent doing all the form-filling and you clicking the final button.**

Version 1.0.0 · Agent Skills format (`SKILL.md`) · Works with Claude Code and any agent that supports Agent Skills and the Chrome DevTools MCP server.

---

## What's in the pack

| Skill | What it does | Stops before |
|---|---|---|
| [`short-video-publish-orchestrator`](skills/short-video-publish-orchestrator/SKILL.md) | Runs all three platforms in one session. Prepares the files, opens three tabs, starts all three uploads, fills them in turn, and hands over one summary | All three final buttons |
| [`youtube-studio-upload`](skills/youtube-studio-upload/SKILL.md) | Uploads a Short (or long video) in YouTube Studio, after checking it's on the right channel | **Publish** |
| [`tiktok-studio-upload`](skills/tiktok-studio-upload/SKILL.md) | Fills a post in TikTok Studio: caption, real hashtags, 3:4 cover, settings, both checks | **Post** |
| [`instagram-reels-upload`](skills/instagram-reels-upload/SKILL.md) | Fills an Instagram Reel in Meta Business Suite: Instagram-only, caption, custom cover, copyright check | **Share** |

Each platform skill works on its own. The orchestrator calls the three platform skills in one coordinated run.

---

## Why it's built this way

**Human in the loop, always.** The agent fills everything in, then stops with the final button visible. You look at the post and click **Publish / Post / Share** yourself. Nothing goes public without you.

**Your real browser, your real accounts.** The agent drives the Chrome profile you're already logged into, through the Chrome DevTools MCP server, exactly the way you'd publish by hand: no keys, no paid posting tools, and every option the platforms' own upload pages offer, including custom cover images.

**Built from real runs.** Every step and every "gotcha" in these skills comes from runs on live accounts: the TikTok caption box that ignores Cmd+A, YouTube's hashtag pop-up that covers the form, Instagram's two look-alike accounts in the "Post to" list, the TikTok music check that starts switched off, and more.

**Safe by design.** The agent:

- checks it's on the **right account or channel** before uploading anything
- **never clicks** the final publish button
- **stops and tells you** when a platform asks for verification, instead of working around it
- does everything in the browser, the same way you would by hand

---

## Requirements

| What | Notes |
|---|---|
| An agent that supports **Agent Skills** | e.g. Claude Code |
| **Chrome DevTools MCP** server | The tools named like `list_pages`, `navigate_page`, `take_snapshot`, `click`, `upload_file`, `evaluate_script`. Set up with `npx chrome-devtools-mcp@latest` (see its docs) |
| **Google Chrome** | One Chrome profile logged into all three platforms |
| Accounts | A YouTube channel; a TikTok account; an Instagram **professional** account connected to a Meta Business Suite portfolio |
| Video | Vertical 9:16, 3 minutes or shorter, `.mp4` |
| Covers (recommended) | 9:16 (YouTube + Instagram) and 3:4 (TikTok) images |
| macOS helpers (optional) | The bundled `.sh` / `.applescript` helpers are for macOS. On Windows or Linux, follow the manual steps in `references/browser-setup.md` |

---

## Installation

1. Copy the folders under `skills/` into your agent's skills directory, e.g. for Claude Code:
    - personal: `~/.claude/skills/`
    - per project: `.claude/skills/` in your project
2. Copy `skills/short-video-publish-orchestrator/assets/publish-config.example.yaml` to `publish-config.yaml` in your project root (or `~/.short-video-publisher/publish-config.yaml`) and fill it in. Start from a preset in `assets/presets/` if one matches you.
3. Make sure the Chrome DevTools MCP server is connected to your agent.
4. Ask your agent something like: *"Upload `videos/final.mp4` to YouTube, TikTok and Instagram"*.

The first time, the agent walks you through anything missing from your config.

---

## What you'll see

At the end of a run the agent leaves three tabs open and reports:

| Platform | Status | Your move |
|---|---|---|
| TikTok | Filled in, both checks "No issues found" | Review, click **Post** |
| Instagram | Filled in, "safe to publish" | Review, click **Share** |
| YouTube | Filled in, Public selected, custom cover set, copyright check 44% | Review, click **Publish** |

See [`examples/example-session.md`](skills/short-video-publish-orchestrator/examples/example-session.md) for a full sample run.

---

## Folder layout

```
short-video-publisher/
├── README.md                ← this file
├── LICENSE.md
├── CHANGELOG.md
└── skills/
    ├── short-video-publish-orchestrator/
    │   ├── SKILL.md
    │   ├── references/      browser setup, metadata format, config reference
    │   ├── assets/          config example, presets, metadata template
    │   ├── examples/        filled-in metadata, sample session
    │   ├── scripts/         open Chrome profile tabs, auto-allow debugging, prepare thumbnails
    │   └── evals/           test prompts
    ├── youtube-studio-upload/
    ├── tiktok-studio-upload/
    └── instagram-reels-upload/
```

---

## Limits and honest notes

- **Platforms change their UI.** These skills describe each page by its visible labels and explain *why* each step exists, so the agent can adapt when a button moves. If a platform redesigns a page heavily, update the matching `references/*-ui.md`.
- **Tested scope (v1.0.0):** vertical Shorts on one English YouTube channel, one TikTok account, one Instagram account, on macOS. Long videos (16:9, scheduled) and a second YouTube channel are supported by the instructions but less tested; see each skill's "Tested scope".
- **Platform rules still apply.** You're responsible for following each platform's terms, disclosing AI-generated content and paid promotions honestly, and owning the rights to your music and footage.
