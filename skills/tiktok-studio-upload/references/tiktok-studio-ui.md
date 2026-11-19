# TikTok Studio: UI Map and Scripts

Snippets for the Chrome DevTools MCP `evaluate_script` tool, for the TikTok tab. If a selector stops matching after a TikTok update, `take_snapshot` and find the element by its visible label; each snippet says what it targets.

## Contents

1. Upload page landmarks
2. Clear the description
3. Hashtag suggestions
4. Verify hashtags
5. Settings and check switches
6. Wait for checks
7. Troubleshooting

---

## 1. Upload page landmarks

| What | How it appears |
|---|---|
| Upload button | button "Select video" |
| Unsaved-draft banner | "A video you were editing wasn't saved. Continue editing?" with Discard / Continue. Ignore it |
| Upload done | text "Uploaded（48.24MB）" (full-width brackets) |
| Onboarding pop-up | alertdialog "Preview your video on your phone…" with "Got it" |
| Description | a combobox with a `[contenteditable=true]` editor, counter "N / 4000" |
| Cover | "Edit cover" → dialog with "Upload cover image", "Cancel", "Save" |
| Settings | radios "Now" / "Schedule", "Who can see this post" (Everyone), "Show more" |
| Final buttons | "Post", "Save draft", "Discard" |

## 2. Clear the description

```js
// Select everything in the description editor. Then press_key Backspace and verify.
() => { const ed = document.querySelector('[contenteditable=true]'); ed.focus(); const r = document.createRange(); r.selectNodeContents(ed); const s = window.getSelection(); s.removeAllRanges(); s.addRange(r); return ed.innerText; }
```

```js
() => JSON.stringify(document.querySelector('[contenteditable=true]').innerText)   // expect "\n" (empty)
```

## 3. Hashtag suggestions

After typing `#tag` (no space):

```js
async () => { await new Promise(r => setTimeout(r, 2000));
  const f = document.querySelector('.hashtag-suggestion-item.focused');
  return { focused: f?.innerText, top: [...document.querySelectorAll('.hashtag-suggestion-item')].slice(0, 4).map(e => e.innerText) }; }
```

`focused` looks like `"#aithumbnail\n1.0K posts"`. Compare the first line with your tag **exactly** (`#aithumbnail` ≠ `#aithumbnails`). Match → `press_key Enter`. No match → `type_text " "` and report it.

## 4. Verify hashtags

```js
() => { const ed = document.querySelector('[contenteditable=true]'); return { text: ed.innerText, hashtags: [...ed.querySelectorAll('.mention')].map(m => m.innerText) }; }
```

`hashtags` should list every tag you converted. `innerText` may show three line breaks between paragraphs (two Enters render as an empty block). That's expected.

## 5. Settings and check switches

After clicking **Show more**:

```js
// List every switch with its label and state
() => [...document.querySelectorAll('[role=switch], input[type=checkbox]')].map(s => { let el = s, label = ''; for (let i = 0; i < 6 && el; i++) { el = el.parentElement; if (el?.innerText?.trim().length > 2) { label = el.innerText.trim().split('\n')[0]; break; } } return { label, on: s.getAttribute('aria-checked') ?? s.checked, disabled: s.disabled || s.getAttribute('aria-disabled') }; })
```

Typical result: High-quality uploads (on, locked) · Comment (on) · Reuse of content (off, locked for videos over 60 s) · Disclose post content (off) · AI-generated content (off) · Audience control (off) · **Music copyright check (off)** · Content check lite (on).

```js
// Switch on Music copyright check
async () => { const sws = [...document.querySelectorAll('[role=switch], input[type=checkbox]')];
  const t = sws.find(s => { let el = s; for (let i = 0; i < 6 && el; i++) { el = el.parentElement; if (el?.innerText?.trim().length > 2) return el.innerText.trim().startsWith('Music copyright check'); } return false; });
  if (!t) return 'not found'; if ((t.getAttribute('aria-checked') ?? String(t.checked)) !== 'true') t.click();
  await new Promise(r => setTimeout(r, 1500)); return t.getAttribute('aria-checked') ?? t.checked; }
```

## 6. Wait for checks

```js
// Poll up to ~60 s; returns the text under each check
async () => { for (let i = 0; i < 20; i++) { const t = document.body.innerText;
    const music = t.split('Music copyright check')[1]?.split('Content check lite')[0]?.trim();
    const content = t.split('Content check lite')[1]?.split('\n').filter(Boolean)[0];
    if (/No issues found/.test(music || '') && /No issues found/.test(content || '')) return { music, content };
    await new Promise(r => setTimeout(r, 3000)); }
  const t = document.body.innerText; return { music: t.split('Music copyright check')[1]?.split('Content check lite')[0]?.trim(), content: t.split('Content check lite')[1]?.split('\n').filter(Boolean)[0] }; }
```

Content check lite may say "Checking in progress. This will take about 10 minutes." In the orchestrator, move on to other tabs and come back.

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| Typed text appended to the file name | Description wasn't cleared: use §2 (not Cmd+A) |
| Hashtag stays grey/plain | It wasn't picked from the list: delete it, retype, press Enter on an exact match |
| Wrong hashtag inserted | Enter was pressed on a non-exact suggestion: delete it, retype, check `focused` first |
| Music check never finishes | It's switched off: §5 |
| Cover looks cropped | Wrong aspect ratio: use a 3:4 image |
| Login page / other account | Stop; ask the user to log in to the configured account in the configured profile |
