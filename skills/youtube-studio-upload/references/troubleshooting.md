# YouTube Studio Upload: Troubleshooting

| Symptom | Cause | What to do |
|---|---|---|
| Studio opens on the wrong channel | Studio remembers the last channel used | Switch account by **handle** (SKILL.md step 2), re-read `CHANNEL_ID` |
| "Oops, something went wrong" on a video link | Tab is in a Chrome profile without access to that channel, or the video was deleted | Open a tab in the configured profile; search the video ID in Studio's search box |
| Link is `watch?v=` instead of `/shorts/` | Video isn't vertical or is over 3 minutes | Stop, tell the user. Don't continue as a Short |
| Typing the title lands in the middle of the old title | `Cmd/Ctrl+A` doesn't select in this box | Script selection + Backspace (`youtube-studio-ui.md` §3) |
| A list of `#hashtags` covers the form | Hashtag suggestions after the description | Real `click` on the title box; never Enter (`youtube-studio-ui.md` §4) |
| "One-time verification needed" after **Upload file** | Daily limit for custom thumbnails on unverified channels | Cancel, **stop**, ask the user to verify in Settings → Channel → Feature eligibility |
| `upload_file` on **Upload file**: "could not accept the file… did not trigger a file chooser" | Usually the verification dialog opened instead of the file chooser | Look for the verification dialog (see above) |
| Thumbnail upload rejected / error about size | File over 2 MB | `scripts/prepare_thumbnail.sh` (JPEG, same size) |
| Browser tool refuses the file path | File is outside folders the browser tool may read | Put the file inside the project (e.g. `.tmp/thumbs/`) |
| AI-use radio "not found" by script | Not a standard radio element | Click it by uid from `take_snapshot` |
| Copyright check says ~10 minutes | Normal for new uploads | Don't wait: Next works. Report the progress at hand-over |
| Dialog shows "Initial check" instead of "Checks" | YouTube renamed the step for some uploads | Same step; treat it the same way |
| After publishing, thumbnail is an auto-frame (`sd2.jpg`) | Thumbnail didn't stick | Tell the user; they can re-upload it in Studio |
