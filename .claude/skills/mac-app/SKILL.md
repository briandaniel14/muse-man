---
name: mac-app
description: Run, screenshot, click and type in the muse-man macOS app, and read its stdout. Use to see a UI change working, or to diagnose runtime behaviour such as an empty search.
---

`scripts/mac-app` drives a separate Debug build of the Mac app; `scripts/mac-app` alone prints its commands.

## Loop

1. `scripts/mac-app build`, then `scripts/mac-app launch`.
2. `scripts/mac-app screenshot` prints a PNG path; Read it.
3. `scripts/mac-app click <x> <y>` takes full-size PNG pixels. When the Read result says "multiply coordinates by N", multiply the displayed coordinates by N first.
4. `scripts/mac-app type "<text>"` types into the focused field. Wait for network-backed results before the next screenshot: Apple Music search takes up to 9 seconds.
5. `scripts/mac-app quit` when done.

## Diagnosing

Silent failures (`try?`) leave no trace, and MusicKit writes nothing to the unified log. Add a temporary `NSLog("DIAG …")` at the suspect call, rebuild, relaunch, reproduce, then `scripts/mac-app log`. The `no_debug_logging` lint rule fails until every `NSLog` is gone again.

## The real store

The Debug build opens the user's real iCloud-synced store. Leave sheets with Cancel and save nothing unless the user asks for test data. CloudKit sync errors in the log are expected: launching from here can't reach `cloudd`.

A first Apple Music search pops the system permission prompt; ask the user before triggering it if authorisation may not have been granted yet.

## iOS

The simulator has no tapping: `xcrun simctl install`, `xcrun simctl launch`, then `xcrun simctl io <udid> screenshot <png>`.
