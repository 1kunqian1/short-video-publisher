# Meta Business Suite Reel Composer: UI Map and Scripts

Snippets for the Chrome DevTools MCP `evaluate_script` tool, for the Instagram tab. If Meta changes the page, use `take_snapshot` and find elements by their visible labels; each snippet says what it targets.

## Contents

1. Composer landmarks
2. "Post to": tell the two options apart
3. Upload status
4. Cover status
5. Share step
6. Troubleshooting

---

## 1. Composer landmarks

| What | How it appears |
|---|---|
| Page title | heading "Create reel"; step buttons "Create / Edit / Share … status" at the top |
| Post to | combobox "Post to {name} and {name}" (both selected) or "Post to {name}" (one) |
| Video | button "Add Video" → after upload: file name, "1080 x 1920", "100%" |
| Caption | textbox "Write into the dialogue box to include text with your post." |
| Thumbnail | buttons "Choose suggested" / "Choose frame" / "Upload image"; after choosing Upload image: link "Upload image" → becomes "Change image" |
| Copyright | "Your video is safe to publish!" / "No copyright issues were found." |
| Buttons | "Cancel", "Next" (Create step) → "Back", "Share" (Share step) |
| Share step | "Scheduling options": "Share now" / "Schedule" / "Save as draft" (often greyed out for Instagram); "Who can see this?": Public / Restricted |

## 2. "Post to": tell the two options apart

Open the dropdown, then:

```js
() => [...document.querySelectorAll('[role=option]')].map((o, i) => ({
  index: i, text: o.innerText.trim(),
  selected: o.getAttribute('aria-selected'),
  platform: (o.innerHTML.match(/Facebook|Instagram/i) || ['?'])[0] }))
```

Click (by snapshot uid) the option whose `platform` is **Facebook** to untick it, then press Escape to close the list. Verify:

```js
() => document.querySelector('[role=combobox]')?.innerText.replace(/\s+/g, ' ').trim()   // expect "Instagram {username}"
```

## 3. Upload status

```js
() => { const t = document.body.innerText; return { percent: t.match(/\d+%/g)?.slice(0, 3), resolution: t.match(/\d{3,4} x \d{3,4}/)?.[0], safe: /safe to publish/.test(t) }; }
```

Expect `percent: ["100%"]`, `resolution: "1080 x 1920"`, and eventually `safe: true`.

## 4. Cover status

After uploading through the **Upload image** link:

```js
() => ({ changeImageLink: [...document.querySelectorAll('a, [role=link]')].some(a => a.innerText.trim() === 'Change image'),
         waiting: /Please wait for the thumbnail to upload/.test(document.body.innerText) })
```

`changeImageLink: true` = cover set. `waiting: true` = Next is temporarily disabled; wait a few seconds.

## 5. Share step

```js
() => ({ step: [...document.querySelectorAll('h3')].map(h => h.innerText.trim()).filter(Boolean).slice(0, 6),
         publicChecked: [...document.querySelectorAll('[role=radio]')].find(r => /^Public/.test(r.getAttribute('aria-label') || r.innerText))?.getAttribute('aria-checked'),
         shareNowPressed: [...document.querySelectorAll('[role=button]')].find(b => b.innerText.trim() === 'Share now')?.getAttribute('aria-pressed'),
         shareButton: [...document.querySelectorAll('[role=button]')].some(b => b.innerText.trim() === 'Share') })
```

Expect Public checked (possibly greyed out), Share now pressed, Share button present. **Don't click Share.**

## 6. Troubleshooting

| Symptom | Fix |
|---|---|
| "Post to" still shows both accounts | You clicked the dropdown box, not the option. Reopen, click the Facebook option itself |
| Wrong option unticked | Both options share a name; check `platform` in §2 before clicking |
| Hashtag suggestion picked by accident | An Enter landed on an open suggestion. Fix the caption text, then close lists with Escape / the thumbnail tab |
| `upload_file` on the "Upload image" tab does nothing | Use the "Upload image" **link** that appears under the tab |
| Next is greyed out | Thumbnail still uploading ("Please wait for the thumbnail to upload."): wait |
| Preview caption has no line breaks | Display only; the real post keeps them |
| "Save as draft" greyed out | Normal for Instagram here; keep the tab open until the user shares |
| Login page / other portfolio | Stop; ask the user to log in in the configured profile; check `asset_id`/`business_id` |
