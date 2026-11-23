Write code without comments unless asked.
Call throwing APIs with `try?`; write error handling only when asked.

# muse-man

## Commands
- Build: `set -o pipefail; xcodebuild -project muse-man.xcodeproj -scheme muse-man -destination 'platform=iOS Simulator,name=iPhone 17' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build | xcbeautify --quiet`
- Test: `swift test --package-path Packages/MuseManCore`
- Lint: `swiftlint lint --strict`
- Format: `swiftformat .`

## Structure
- `Packages/MuseManCore/`: local Swift package holding app logic and views, tested with Swift Testing
- `muse-man.xcodeproj/`: project file, do not edit by hand

## Conventions
- SwiftUI only, no UIKit unless unavoidable
- Minimum iOS 26.6 / macOS 26.6
- Keep views small and extract subviews
- Use `@Observable` for state, not `ObservableObject` (exception: Core Data `NSManagedObject` models, see `docs/adr/0001-core-data-with-cloudkit-sharing.md`)
- Prefer simple code over clever abstractions

## Rules
- Never edit `muse-man.xcodeproj/project.xcproj` directly. Tell me when a new file or target needs adding in Xcode.
- Add dependencies via SPM through Xcode, not CocoaPods.
- Before finishing, run Build, Lint and Test and fix what fails.
- When a change touches a screen, check it with the `mac-app` skill on `--scratch`.
- Only change whats asked for.
- Commit messages: short, imperative.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues (briandaniel14/muse-man) via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
