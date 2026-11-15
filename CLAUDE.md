Do not write any comments unless asked
Do not do any error handling unless asked

# muse-man

iOS app built with SwiftUI in Xcode.

## Commands
- Build: `xcodebuild -project muse-man.xcodeproj -scheme muse-man -destination 'platform=iOS Simulator,name=iPhone 16' build | xcbeautify`
- Test: `xcodebuild test -project muse-man.xcodeproj -scheme muse-man -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify`
- Lint: `swiftlint lint --strict`
- Format: `swiftformat .`
- List simulators: `xcrun simctl list devices available`

## Structure
- `muse-man/`: app source (`MyApp.swift` is the entry point, `ContentView.swift` is the root view)
- `muse-man.xcodeproj/`: project file, do not edit by hand

## Conventions
- SwiftUI only, no UIKit unless unavoidable
- Minimum iOS 17
- Keep views small and extract subviews
- Use `@Observable` for state, not `ObservableObject`
- Prefer simple code over clever abstractions

## Rules
- Never edit `project.pbxproj` directly. Tell me when a new file or target needs adding in Xcode.
- Add dependencies via SPM through Xcode, not CocoaPods.
- After changes, run build, lint and tests, and fix any errors before finishing.
- Only change whats asked for.
- Commit messages: short, imperative.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues (briandaniel14/muse-man) via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
