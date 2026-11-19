#!/usr/bin/env bash
# Open N blank Chrome windows in a specific Chrome profile (macOS).
#
# Why: the Chrome DevTools MCP tool `new_page` opens tabs in Chrome's DEFAULT profile,
# which is often logged into different accounts. Opening windows from the command line
# with --profile-directory puts them in the profile that holds your publishing logins.
#
# Usage: open_profile_tabs.sh "Profile 3" [count]
#   "Profile 3" = directory name from chrome://version → Profile Path (last folder)
#   count       = number of windows to open (default 1)
#
# Afterwards, call the MCP `list_pages` tool and pick the new `about:blank` pages.

set -euo pipefail

PROFILE="${1:-}"
COUNT="${2:-1}"

if [[ -z "$PROFILE" ]]; then
    echo "Usage: $0 \"Profile N\" [count]" >&2
    exit 1
fi

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This helper is for macOS. On Windows/Linux see references/browser-setup.md §6." >&2
    exit 2
fi

for ((i = 1; i <= COUNT; i++)); do
    open -na "Google Chrome" --args --profile-directory="$PROFILE" --new-window "about:blank"
    sleep 1
done

echo "Opened $COUNT window(s) in Chrome profile \"$PROFILE\". Now run list_pages."
