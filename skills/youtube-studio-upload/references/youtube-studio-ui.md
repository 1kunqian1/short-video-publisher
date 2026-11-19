# YouTube Studio: UI Map and Scripts

Ready-made `evaluate_script` snippets for the upload dialog. Pass them to the Chrome DevTools MCP `evaluate_script` tool with the YouTube tab's `pageId`.

YouTube changes element names now and then. Every snippet below also says **what it's looking for**, so if a selector stops matching, use `take_snapshot` and find the element by its visible label.

## Contents

1. Channel check and switch
2. Upload dialog anatomy
3. Title
4. Description and the hashtag pop-up
5. Thumbnail
6. Advanced settings
7. Moving between steps
8. Visibility
9. After publishing

---

## 1. Channel check and switch

```js
() => ({ id: ytcfg.get('CHANNEL_ID'), name: document.querySelector('#entity-name')?.innerText?.trim() })
```

Switching: click `button "Account"` (top right avatar) → **Switch account**. The channel list items are `ytd-account-item-renderer` elements:

```js
// List channels in the Switch account menu
() => [...document.querySelectorAll('ytd-account-item-renderer')].map(e => e.innerText.replace(/\s+/g, ' ').trim())
```

```js
// Click the one with the target handle (replace @mychannel). The page navigates afterwards.
() => { const h = '@mychannel'; const it = [...document.querySelectorAll('ytd-account-item-renderer')].find(e => e.innerText.split(/\s+/).includes(h)); it?.click(); return !!it; }
```

Match the handle as a **whole word** (`split(/\s+/).includes(...)`): `@mychannel` is a prefix of `@mychannel_cn`, so a plain `includes` could pick the wrong one.

## 2. Upload dialog anatomy

- Root: `ytcp-uploads-dialog`
- Step tabs (`[role=tab]`): **Details · Video elements · Checks** (or **Initial check**) **· Visibility**
- Current step: `ytcp-uploads-dialog [role=tab][aria-selected=true]`
- Next button: `#next-button`; final button: `#done-button` (reads Save / Publish / Schedule)
- Top-left status: "Saved as private" / "Saving…" / "All changes saved."
- Footer: upload and check progress ("Uploading 39%…", "Checking 34%… 7 minutes left", "Checks complete. No issues found.")

## 3. Title

```js
// Select all text in the title box (Cmd/Ctrl+A doesn't work here). Then press Backspace with press_key, then type_text.
() => { const ed = document.querySelector('ytcp-uploads-dialog #title-textarea #textbox'); ed.focus(); const r = document.createRange(); r.selectNodeContents(ed); const s = getSelection(); s.removeAllRanges(); s.addRange(r); return s.toString(); }
```

```js
// Verify
() => document.querySelector('ytcp-uploads-dialog #title-textarea #textbox')?.innerText
```

## 4. Description and the hashtag pop-up

Click the description textbox (snapshot label "Tell viewers about your video…"), then `type_text` each paragraph and `press_key Enter` twice between paragraphs.

After the last hashtag, a list of suggestions (e.g. `#geminiai`, `#geminiaitutorial`, …) stays open and covers the right side of the dialog.

- **Don't press Enter** (picks a suggestion) or Escape.
- A script `.click()` elsewhere does **not** close it; it needs a real focus change.
- **Close it:** use the `click` tool on the **title textbox** uid.

```js
// Check the list is gone and nothing changed
() => ({ popupItems: [...document.querySelectorAll('tp-yt-paper-item, [role=option]')].filter(e => e.offsetParent && /^#/.test(e.innerText.trim())).length,
         title: document.querySelector('ytcp-uploads-dialog #title-textarea #textbox')?.innerText,
         descEnd: document.querySelector('ytcp-uploads-dialog #description-textarea #textbox')?.innerText.slice(-80) })
```

## 5. Thumbnail

`upload_file` on the **Upload file** button uid. Then:

```js
// Look for the verification prompt and the uploaded image
async () => { await new Promise(r => setTimeout(r, 3000));
  const verify = [...document.querySelectorAll('[role=dialog], tp-yt-paper-dialog')].map(d => d.innerText).find(t => /verification/i.test(t));
  const field = [...document.querySelectorAll('ytcp-uploads-dialog button')].map(b => b.innerText.trim()).find(t => /\.(jpe?g|png)$/i.test(t));
  return { verifyPrompt: verify?.slice(0, 160) || null, thumbnailFile: field || null }; }
```

- `verifyPrompt` not null → **Cancel** that dialog and stop (SKILL.md step 4.3).
- `thumbnailFile` shows the file name → done. A screenshot of the Thumbnail area confirms the image.
- The file input (`input#file-loader` inside `ytcp-thumbnail-uploader`) is hidden. Don't make it visible or send files to it directly to get past the verification prompt.

## 6. Advanced settings

Click **Show advanced settings**, then take a fresh `take_snapshot`; the uids below come from it.

| Field | How |
|---|---|
| Not made for kids | radio "No, it's not made for kids" (in the main Audience section) |
| Paid promotion | radio "No, my video doesn't include paid promotion" |
| AI use | radio "No, AI wasn't used" / "Yes, AI was used". Click by **uid**; a script search by radio element name won't find these |
| Tags | click textbox "Tags", `type_text` `tag one, tag two, tag three,` (trailing comma) |
| Video language | click button "Video language …", then script-click the menu item (below) |
| Category | click the category button (shows current value, e.g. "People & Blogs"), then script-click the item |
| Comments | button "Comments On" by default; leave it |

```js
// Pick an item in an open dropdown menu by exact text (replace the text)
async () => { await new Promise(r => setTimeout(r, 800)); const it = [...document.querySelectorAll('tp-yt-paper-item')].filter(e => e.offsetParent).find(e => e.innerText.trim() === 'Science & Technology'); it?.click(); return !!it; }
```

```js
// Verify everything at once
() => { const d = document.querySelector('ytcp-uploads-dialog');
  const triggers = [...d.querySelectorAll('ytcp-form-select, ytcp-dropdown-trigger')].map(e => e.innerText.replace(/\s+/g, ' ').trim());
  return { chips: [...d.querySelectorAll('ytcp-chip')].map(c => c.innerText.trim()),
           checked: [...d.querySelectorAll('[aria-checked="true"]')].map(e => (e.innerText || '').trim().slice(0, 50)).filter(Boolean),
           language: triggers.find(t => t.startsWith('Video language')),
           comments: triggers.find(t => t.startsWith('Comments')) }; }
```

In `checked`, the AI-use radio may show only as "No".

## 7. Moving between steps

```js
// Click Next and report where you are
async () => { const d = document.querySelector('ytcp-uploads-dialog'); d.querySelector('#next-button').click(); await new Promise(r => setTimeout(r, 1500)); return d.querySelector('[role=tab][aria-selected=true]')?.innerText.trim(); }
```

Next stays clickable while checks are running, so you don't need to wait on the Checks step.

## 8. Visibility

```js
// Select Public and confirm the final button
async () => { const d = document.querySelector('ytcp-uploads-dialog'); d.querySelector('tp-yt-paper-radio-button[name="PUBLIC"]').click(); await new Promise(r => setTimeout(r, 1000));
  return { radios: [...d.querySelectorAll('tp-yt-paper-radio-button[name]')].map(r => r.getAttribute('name') + ':' + r.getAttribute('aria-checked')),
           finalButton: d.querySelector('#done-button')?.innerText.trim() }; }
```

Expected: `PUBLIC:true` and `finalButton: "Publish"`. **Don't click `#done-button`.**

If the user clicks around, the dialog may end up on another step. Before handing over, click the **Visibility** tab and re-check:

```js
async () => { const d = document.querySelector('ytcp-uploads-dialog'); [...d.querySelectorAll('[role=tab]')].find(t => t.innerText.trim() === 'Visibility')?.click(); await new Promise(r => setTimeout(r, 1200));
  return { public: d.querySelector('tp-yt-paper-radio-button[name="PUBLIC"]')?.getAttribute('aria-checked'), finalButton: d.querySelector('#done-button')?.innerText.trim(),
           checks: d.innerText.split('\n').filter(l => /Check|issues/.test(l)).slice(-2) }; }
```

## 9. After publishing

Open `https://studio.youtube.com/video/{id}/edit`:

```js
() => ({ channel: ytcfg.get('CHANNEL_ID'),
         visibility: (document.body.innerText.match(/\b(Private|Public|Unlisted|Scheduled)\b/) || [])[0],
         link: (document.body.innerText.match(/https:\/\/youtube\.com\/shorts\/[\w-]+/) || [])[0],
         thumbs: [...document.querySelectorAll('img')].map(i => i.src).filter(s => s.includes('/vi/')).slice(0, 3) })
```

A real custom thumbnail URL contains `sddefault.jpg?v=`. Auto-picked frames look like `sd1.jpg` / `sd2.jpg` / `sd3.jpg`.
