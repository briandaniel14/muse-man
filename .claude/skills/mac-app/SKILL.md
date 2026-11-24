---
name: mac-app
description: Run, screenshot, click and type in the muse-man macOS app, and read its stdout. Use to see a UI change working, or to diagnose runtime behaviour such as an empty search.
---

`scripts/mac-app` drives a separate Debug build of the Mac app; `scripts/mac-app` alone prints its commands.

## Loop

1. `scripts/mac-app build`, then `scripts/mac-app launch` (see Stores for `--scratch`).
2. `scripts/mac-app screenshot <name>` prints a PNG path; Read it. Shots land outside the repo, per branch, so they survive worktree cleanup: name them after what they show (`after-song-screen`) and quote the paths in your report as evidence.
3. `scripts/mac-app click <x> <y>` takes full-size PNG pixels. When the Read result says "multiply coordinates by N", multiply the displayed coordinates by N first.
4. `scripts/mac-app type "<text>"` types into the focused field. Wait for network-backed results before the next screenshot: Apple Music search takes up to 9 seconds.
5. `scripts/mac-app quit` when done.

Beyond the main window: `scripts/mac-app windows` lists the app's windows, numbered oldest first; put `--window <n>` before any command to act on window n, such as the Settings window ⌘, opens. `drag <x1> <y1> <x2> <y2>` reorders a list, and `resize <w> <h>` (points) checks narrow layouts.

On "screen locked", stop and ask the user to unlock the Mac: nothing can be captured until they do.

## Diagnosing

Silent failures (`try?`) leave no trace, and MusicKit writes nothing to the unified log. Add a temporary `NSLog("DIAG …")` at the suspect call, rebuild, relaunch, reproduce, then `scripts/mac-app log`. The `no_debug_logging` lint rule fails until every `NSLog` is gone again.

## Stores

- `scripts/mac-app launch --scratch` opens an in-memory store seeded with a few of everything (`SeedData.swift`), fresh on every launch and never synced. Use it for anything that saves: reproducing a bug, checking a fix, filling a screen with data.
- `scripts/mac-app launch` opens the user's real iCloud-synced store. Use it only to look: leave sheets with Cancel and save nothing. CloudKit sync errors in the log are expected: launching from here can't reach `cloudd`.

A bug that shows in the real store but not in the scratch store points at sync.

A first Apple Music search pops the system permission prompt; ask the user before triggering it if authorisation may not have been granted yet.

## iOS

The simulator has no tapping: `xcrun simctl install`, `xcrun simctl launch`, then `xcrun simctl io <udid> screenshot <png>`.
