# Browser Setup: Open the Right Profile and Connect Chrome DevTools MCP

Every skill in this pack drives the user's real Chrome through the **Chrome DevTools MCP** server. This file explains how to get a tab in the **right Chrome profile** and connect to it reliably.

## Contents

1. Why the profile matters
2. Find the profile directory
3. Open tabs in that profile
4. Connect the MCP (and the "Allow remote debugging?" prompt)
5. Pick your tabs
6. Windows and Linux
7. Troubleshooting

---

## 1. Why the profile matters

Each Chrome profile has its own logins. The user's YouTube, TikTok and Meta Business Suite sessions live in **one specific profile**, set in `publish-config.yaml → browser.chrome_profile_directory`.

The MCP tool `new_page` opens tabs in Chrome's **default** profile, which is often logged into a different Google account (a different YouTube channel), or into nothing at all. So **don't use `new_page`** for publishing. Open tabs from the command line in the configured profile, then find them with `list_pages`.

## 2. Find the profile directory

The config needs the profile's **directory name** (e.g. `Default`, `Profile 1`, `Profile 3`), not its display name.

- In the right profile, open `chrome://version` and read **Profile Path**. The last folder is the directory name.
- Or, on macOS, read the mapping from Chrome's `Local State` file:

```bash
python3 -c "import json,os;d=json.load(open(os.path.expanduser('~/Library/Application Support/Google/Chrome/Local State')));[print(k,'→',v.get('name')) for k,v in d['profile']['info_cache'].items()]"
```

## 3. Open tabs in that profile

macOS (bundled helper):

```bash
scripts/open_profile_tabs.sh "Profile 3" 3     # 3 new about:blank windows in that profile
```

What it runs, if you prefer to do it by hand:

```bash
open -na "Google Chrome" --args --profile-directory="Profile 3" --new-window "about:blank"
```

If Chrome is already running, this adds a window to the running Chrome, in that profile. If not, it starts Chrome, which the MCP needs anyway.

## 4. Connect the MCP

The first time the MCP connects in a Chrome session, Chrome may show a sheet: **"Allow remote debugging?"** with *Allow / Cancel*. Until someone clicks **Allow**, `list_pages` waits and can't be cancelled by the agent.

**On macOS, start the helper first, then connect right away:**

```bash
osascript scripts/allow_remote_debugging.applescript > /dev/null 2>&1 &
sleep 1 && ps aux | grep '[o]sascript'      # make sure it's running
```

Then call `list_pages` immediately. The helper checks every second for 60 seconds and clicks **Allow** when the sheet appears. It needs macOS Accessibility permission for the app running your agent (System Settings → Privacy & Security → Accessibility).

The order matters: helper first, `list_pages` second. If you call `list_pages` first, nothing is there to click Allow and the call hangs.

**No helper (any OS):** tell the user "Chrome may ask to allow remote debugging; please click Allow", then call `list_pages`.

## 5. Pick your tabs

`list_pages` returns every open tab with an ID. The tabs you just opened show as `about:blank`. Assign one per platform and keep using those IDs (pass `pageId` to every tool call). Never navigate the user's own tabs (mail, documents) away from what they were doing.

Page IDs can change if tabs are closed. If a call fails with "No page found", run `list_pages` again and re-identify your tabs by URL.

## 6. Windows and Linux

Open a tab in a profile:

```powershell
# Windows
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --profile-directory="Profile 3" --new-window about:blank
```

```bash
# Linux
google-chrome --profile-directory="Profile 3" --new-window about:blank &
```

The "Allow remote debugging?" prompt has no bundled auto-clicker on these systems; ask the user to click Allow.

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "Could not connect to Chrome… DevToolsActivePort" | Chrome isn't running | Open a profile window (step 3), retry |
| `list_pages` hangs | Allow prompt not clicked | User clicks Allow; on macOS restart the helper, then retry |
| YouTube Studio shows a different channel, or "Oops, something went wrong" on a video link | Tab is in the wrong profile | Close it, open one with step 3 |
| A site shows a login page | Not logged in in this profile | Stop, ask the user to log in in this profile |
