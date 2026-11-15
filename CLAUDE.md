Do not write any comments unless asked
Do not do any error handling unless asked

# muse-man

iOS app built with SwiftUI in Xcode.

## Commands
- Build: `xcodebuild -project muse-man.xcodeproj -scheme muse-man -destination 'platform=iOS Simulator,name=iPhone 17' build | xcbeautify`
- Test: `swift test --package-path Packages/MuseManCore`
- Lint: `swiftlint lint --strict`
- Format: `swiftformat .`
- List simulators: `xcrun simctl list devices available`

## Structure
- `muse-man/`: app source (`MyApp.swift` is the entry point, `ContentView.swift` is the root view)
- `Packages/MuseManCore/`: local Swift package holding app logic and views, tested with Swift Testing
- `muse-man.xcodeproj/`: project file, do not edit by hand

## Conventions
- SwiftUI only, no UIKit unless unavoidable
- Minimum iOS 26.6 / macOS 26.6
- Keep views small and extract subviews
- Use `@Observable` for state, not `ObservableObject` (exception: Core Data `NSManagedObject` models, see `docs/adr/0001-core-data-with-cloudkit-sharing.md`)
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
