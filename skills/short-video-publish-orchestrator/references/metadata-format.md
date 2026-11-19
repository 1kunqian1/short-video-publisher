# Metadata Note Format

All three platform skills read **one metadata note per video**: a Markdown file with YAML frontmatter. A blank template is in `assets/metadata-template.md`; a filled-in example is in `examples/example-metadata.md`.

The note holds **text and settings only**. The video and cover files are found separately (from the user, or `publish-config.yaml → assets`), so renaming a file never breaks the note.

---

## Frontmatter

```yaml
---
type: upload-metadata
video_type: short          # short | long
project: My Video Name
status: ready              # draft | ready | published
youtube_channel: main      # key from publish-config.yaml → youtube.channels
---
```

## Sections and who reads them

| Section | YouTube | TikTok | Instagram | Notes |
|---|---|---|---|---|
| `## Title` | ✅ Title | – | – | TikTok and Instagram have no title field. Keep it under 100 characters; under 60 shows fully on mobile |
| `## Caption` (one code block) | ✅ Description | ✅ Description | ✅ Caption | One caption for all three. First line ≤ 125 characters (Instagram cuts there). Blank line between paragraphs. Hashtags on the last line |
| `## YouTube → Tags` | ✅ Tags | – | – | Comma-separated, total under 500 characters |
| `## YouTube → Settings` | ✅ | – | – | Category, Made for kids, Language, AI use, Paid promotion, Comments |
| `## TikTok → Settings` | – | ✅ | – | Who can watch, Comments, AI-generated content, Disclose post content |
| `## Instagram → Settings` | – | – | ✅ | AI label, Paid partnership, Share to Feed |
| `## Needs Your Input` | | | | Open questions for the user. Listed in the final report, not a blocker if the user asked to publish |

## Visibility and scheduling

- **Shorts** are published as soon as the user clicks the final button. The skills select **Public** (YouTube), **Now** (TikTok) and **Share now** (Instagram), then stop.
- **Scheduled posts:** if the note gives a time (`Schedule: 2026-03-25 15:00 America/Los_Angeles`), the skills choose **Schedule** and enter it instead. The time must be at least 3 hours ahead on YouTube; if it isn't, tell the user and ask for a new time, rather than guessing.

## Writing the caption so it works everywhere

- **Hashtags on their own last line**, each one word with no spaces: `#aithumbnail #youtubethumbnail`. TikTok and Instagram turn them into real hashtags only when picked from their suggestion list; the platform skills do that.
- **3–5 hashtags** is enough. Long hashtag lists look like spam on all three platforms.
- **No links in the caption** for TikTok and Instagram: they aren't clickable there.
- **No angle-bracket placeholders** or template markers left in the final text.
