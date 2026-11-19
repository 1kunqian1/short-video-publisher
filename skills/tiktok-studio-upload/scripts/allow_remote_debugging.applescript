-- allow_remote_debugging.applescript (macOS)
--
-- Watches Google Chrome for the "Allow remote debugging?" sheet that appears when the
-- Chrome DevTools MCP connects, and clicks "Allow".
--
-- Usage (start it FIRST, then call the MCP `list_pages` right away):
--   osascript allow_remote_debugging.applescript > /dev/null 2>&1 &
--
-- Behaviour:
--   * checks every second for 60 seconds
--   * keeps watching after a click, in case a second prompt appears
--   * exits quietly if no prompt shows up
--
-- Requirement: the app running your agent (Terminal, iTerm, VS Code, …) needs
-- Accessibility permission: System Settings → Privacy & Security → Accessibility.
--
-- How the button is found: the prompt is a sheet on a Chrome window. Its buttons have no
-- `name`, but their `description` is "Allow" / "Cancel" / "Turn off in settings".
-- The script matches description "Allow"; if Chrome changes that, it falls back to the
-- right-most button in the sheet (where "Allow" sits).

tell application "System Events"
    set clickCount to 0
    repeat 60 times
        try
            tell process "Google Chrome"
                repeat with w in (every window)
                    try
                        repeat with s in (every sheet of w)
                            if name of s contains "Allow" then
                                set allItems to entire contents of s
                                set targetBtn to missing value
                                -- 1st choice: the button described as "Allow"
                                repeat with item_ in allItems
                                    try
                                        if class of item_ is button and description of item_ is "Allow" then
                                            set targetBtn to item_
                                            exit repeat
                                        end if
                                    end try
                                end repeat
                                -- fallback: the right-most button
                                if targetBtn is missing value then
                                    set maxX to 0
                                    repeat with item_ in allItems
                                        try
                                            if class of item_ is button then
                                                set p to position of item_
                                                if item 1 of p > maxX then
                                                    set maxX to item 1 of p
                                                    set targetBtn to item_
                                                end if
                                            end if
                                        end try
                                    end repeat
                                end if
                                if targetBtn is not missing value then
                                    click targetBtn
                                    set clickCount to clickCount + 1
                                end if
                            end if
                        end repeat
                    end try
                end repeat
            end tell
        end try
        delay 1
    end repeat
    if clickCount > 0 then
        return "Clicked Allow " & clickCount & " time(s)"
    else
        return "No Allow prompt within 60 seconds"
    end if
end tell
