# Short Video Publisher: Agent Skills Pack

**Post one vertical short video to YouTube Shorts, TikTok and Instagram Reels from your own Chrome. An AI agent fills in every form, then you click the final button.**

Version 1.0.0 · Agent Skills format (`SKILL.md`) · Works with Claude Code and any agent that supports Agent Skills and the Chrome DevTools MCP server.

---

## How it works

```
 You prepare              The agent does                              You finish
┌──────────────┐   ┌──────────────────────────────────────────┐   ┌──────────────────┐
│ 1. Video     │   │ checks the video and your accounts       │   │ review each tab  │
│ 2. Covers    │ → │ opens 3 tabs, starts all 3 uploads       │ → │ click Publish /  │
│ 3. Metadata  │   │ fills titles, captions, hashtags, covers │   │ Post / Share     │
└──────────────┘   │ stops before every final button          │   └──────────────────┘
                   └──────────────────────────────────────────┘
```

The agent never posts anything itself. You get the last look and the last click.

---

## What's in the pack

| Skill | Use it when | Stops before |
|---|---|---|
| [`short-video-publish-orchestrator`](skills/short-video-publish-orchestrator/SKILL.md) | You want **all three platforms** in one run | All three final buttons |
| [`youtube-studio-upload`](skills/youtube-studio-upload/SKILL.md) | **YouTube only** (Shorts or long videos) | **Publish** |
| [`tiktok-studio-upload`](skills/tiktok-studio-upload/SKILL.md) | **TikTok only** | **Post** |
| [`instagram-reels-upload`](skills/instagram-reels-upload/SKILL.md) | **Instagram only** (through Meta Business Suite) | **Share** |

You don't pick a skill yourself. Describe what you want ("post this everywhere", "put this on TikTok") and the agent picks the matching one.

---

# Part A: One-time setup

Do this once. After that, every new video only needs Part B.

### Step A1: Check you have everything

| What | Details |
|---|---|
| An agent that supports **Agent Skills** | e.g. Claude Code |
| **Chrome DevTools MCP** server | Lets the agent control Chrome. Set it up with `npx chrome-devtools-mcp@latest` (see its docs) |
| **Google Chrome** | **One** Chrome profile that is logged into YouTube, TikTok and Meta Business Suite |
| Accounts | A YouTube channel · a TikTok account · an Instagram **professional** account connected to a Meta Business Suite portfolio |
| macOS (optional) | The bundled helper scripts are for macOS. On Windows or Linux, follow the manual steps in [`browser-setup.md`](skills/short-video-publish-orchestrator/references/browser-setup.md) §6 |

### Step A2: Install the skills

Copy the four folders under `skills/` into your agent's skills folder. For Claude Code:

- for all your projects: `~/.claude/skills/`
- for one project only: `.claude/skills/` inside that project

### Step A3: Create your config file

The config file tells the agent **which accounts are yours**, so it can check it's on the right one before uploading.

1. Copy `skills/short-video-publish-orchestrator/assets/publish-config.example.yaml` to **`publish-config.yaml`** in your project root (or to `~/.short-video-publisher/publish-config.yaml`).
    - One YouTube channel? Start from `assets/presets/single-channel-creator.yaml` instead.
    - Two YouTube channels (e.g. one per language)? Start from `assets/presets/bilingual-two-channels.yaml`.
2. Replace every value marked `CHANGE ME`:

| Field | Where to find it |
|---|---|
| `chrome_profile_directory` | In the Chrome profile you use, open `chrome://version` → **Profile Path** → the last folder (e.g. `Profile 1`) |
| YouTube `channel_id` | The YouTube Studio URL: `studio.youtube.com/channel/UC...` (starts with `UC`) |
| YouTube `handle` | Studio → Customization → Basic info → Handle |
| TikTok `handle` | Your `@handle` |
| Instagram `username` | Your username, without `@` |
| Instagram `asset_id` and `business_id` | Open Meta Business Suite with your Instagram account selected. Both numbers are in the URL |

Every field is explained in [`config-reference.md`](skills/short-video-publish-orchestrator/references/config-reference.md).

> **Don't want to fill it in by hand?** Skip this step. On the first run the agent offers to create the file and asks only for what's missing.

### Step A4: Connect Chrome

1. Make sure the Chrome DevTools MCP server is connected to your agent.
2. **macOS only:** give your agent's app **Accessibility** permission (System Settings → Privacy & Security → Accessibility). This lets the bundled helper click Chrome's **"Allow remote debugging?"** prompt for you. Without it, you click **Allow** yourself when Chrome asks.

Setup is done.

---

# Part B: Publishing a video (every time)

### Step B1: Prepare 3 things first ⭐

Get these ready **before** you ask the agent to upload. The run is faster and the result is better.

| # | What | Rules |
|---|---|---|
| 1 | **The final video** | `.mp4`, **vertical 9:16**, **3 minutes or shorter**. Anything longer or horizontal, YouTube treats as a normal video, not a Short. Use the final export, not a rough cut |
| 2 | **Cover images (thumbnails)** | **9:16** for YouTube and Instagram, plus **3:4** for TikTok. Large PNGs are fine: the agent shrinks the YouTube copy to under 2 MB |
| 3 | **A metadata note** | One Markdown file per video with the text and settings for all three platforms (see below) |

**Keep all files inside your project folder.** Chrome can't upload files from `/tmp` or system folders.

#### Writing the metadata note

Copy [`metadata-template.md`](skills/short-video-publish-orchestrator/assets/metadata-template.md) next to your video and fill it in. A filled-in real example: [`example-metadata.md`](skills/short-video-publish-orchestrator/examples/example-metadata.md).

| Section | What to write | Used by |
|---|---|---|
| **Title** | Under 100 characters (under 60 shows in full on phones) | YouTube only |
| **Caption** | **One caption for all three platforms.** First line 125 characters or less (Instagram cuts there). Hashtags on the last line | All three |
| **Schedule** | "now", or a date and time at least 3 hours ahead | All three |
| **YouTube: Tags / Settings** | Tags, category, made for kids, language, AI use, paid promotion, comments | YouTube |
| **TikTok: Settings** | Who can watch, comments, AI-generated content, disclosure | TikTok |
| **Instagram: Settings** | Post to, AI label, paid partnership | Instagram |
| **Needs Your Input** | Anything you haven't decided yet | Listed in the final report |

Caption tips:

- **3 to 5 hashtags**, each one word, all on the last line: `#aithumbnail #youtubethumbnail`
- **No links**: they aren't clickable on TikTok or Instagram
- Turn on the **AI label** if the video shows realistic AI-generated people, scenes or voices. The platforms require it

> **No metadata note yet?** The agent can write one with you before it opens the browser. **No cover?** The upload still works: TikTok keeps its auto-picked frame and the agent tells you in the report.

### Step B2: Make sure Chrome is ready

- Log into YouTube, TikTok and Meta Business Suite **in the profile from your config**.
- You can leave your other tabs open. The agent opens its own new tabs and doesn't touch yours.

### Step B3: Ask the agent

Give it the video and the metadata note:

> *"Upload `videos/my-short/final.mp4` to YouTube, TikTok and Instagram. Metadata is in `videos/my-short/upload-metadata.md`."*

Only one platform?

> *"Put `final.mp4` on TikTok."*

### Step B4: Let the agent work

The agent works through these stages. You don't need to do anything unless it stops and asks:

| Stage | What happens |
|---|---|
| 1. Load config | Finds `publish-config.yaml` |
| 2. Check inputs | Confirms the video is vertical and 3 minutes or shorter, reads the metadata, prepares the YouTube cover |
| 3. Open tabs | Opens 3 new tabs in **your** Chrome profile and connects to them |
| 4. Start uploads | Checks each account is the right one, then starts all three uploads at once (uploads are the slow part) |
| 5. Fill in | Switches between tabs while each one processes: title, caption, real hashtags, cover, settings, copyright checks |
| 6. Hand over | Re-checks every tab and gives you a summary |

**It will stop and ask you when:**

- a page shows a **login** screen → log in (in the configured profile), then tell it to continue
- a platform asks for **verification**, a CAPTCHA, or "confirm it's you" → only you can do this; tell it when you're done
- it's on the **wrong account** and can't switch → it won't upload there

Smaller problems (a hashtag with no match, a caption that's too long) don't stop the run. They show up in the final report.

### Step B5: Review and publish

At the end you get three tabs and a summary like this:

| Platform | Status | Your move |
|---|---|---|
| TikTok | Filled in, both checks "No issues found" | Review, click **Post** |
| Instagram | Filled in, "safe to publish" | Review, click **Share** |
| YouTube | Filled in, Public selected, custom cover set, copyright check 44% | Review, click **Publish** |

Read the **"Needs your attention"** list under the table, look over each tab, then click the three buttons yourself.

### Step B6: Tell the agent you've posted

Say *"Posted all three."* The agent then:

- collects the three public links and writes them into the metadata note's **Published** section
- deletes the temporary files it made (e.g. `.tmp/thumbs/`)

See the full sample run in [`example-session.md`](skills/short-video-publish-orchestrator/examples/example-session.md).

---

## Safety rules the agent always follows

- **Never clicks** Publish, Post or Share
- **Checks the account or channel** before uploading anything
- **Stops and tells you** at any login, verification or CAPTCHA, and never works around it
- Works only in **your browser**, on each platform's own upload page: no API keys, no paid posting tools

---

## Troubleshooting

| Problem | Fix |
|---|---|
| The agent seems stuck right after opening Chrome | Chrome is showing **"Allow remote debugging?"**. Click **Allow** |
| YouTube shows the wrong channel or "Oops, something went wrong" | The tab opened in the wrong Chrome profile. Check `chrome_profile_directory` in your config |
| A site asks you to log in | You're not logged in in that profile. Log in there, then say "continue" |
| YouTube: "One-time verification needed" for thumbnails | Verify in **Studio → Settings → Channel → Feature eligibility**, then say "continue" |
| A button moved or a page looks different | Platforms change their pages. The agent matches buttons by their labels and adapts; if it can't, it stops and asks |

More: the "When something goes wrong" table in the [orchestrator skill](skills/short-video-publish-orchestrator/SKILL.md) and §7 of [`browser-setup.md`](skills/short-video-publish-orchestrator/references/browser-setup.md).

---

## Why it's built this way

**Human in the loop.** An unreviewed public post can't be taken back cleanly, so the final click is always yours.

**Your real browser, your real accounts.** The agent publishes the way you would by hand, so you get every option the upload pages offer, including custom covers.

**Built from real runs.** Every step and "gotcha" comes from runs on live accounts: the TikTok caption box that ignores Cmd+A, YouTube's hashtag pop-up that covers the form, Instagram's two look-alike accounts in the "Post to" list, the TikTok music check that starts switched off, and more.

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

- **Platforms change their UI.** The skills describe each page by its visible labels and explain *why* each step exists, so the agent can adapt when a button moves. If a platform redesigns a page heavily, update the matching `references/*-ui.md`.
- **Tested scope (v1.0.0):** vertical Shorts on one English YouTube channel, one TikTok account and one Instagram account, on macOS. Each platform was tested separately up to the final button; running all three in one session follows the same pattern but hasn't been timed end to end. Long videos (16:9, scheduled) and a second YouTube channel are supported by the instructions but less tested.
- **Platform rules still apply.** You're responsible for following each platform's terms, disclosing AI-generated content and paid promotions honestly, and owning the rights to your music and footage.
- **Not affiliated** with or endorsed by Google, YouTube, TikTok, ByteDance or Meta.

## License

[MIT](LICENSE.md). Free to use, modify and share; keep the copyright notice.
