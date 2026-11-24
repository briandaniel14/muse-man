# Testing

The user has agreed these two seams in advance. They answer the `tdd` skill's "confirm the seams with the user" step: write tests at them without asking. A test anywhere else needs the user's agreement first. This extends the single seam in `docs/specs/v1.md` → Testing Decisions.

## Seam 1: `PracticeLibrary`

Drive `PracticeLibrary` through its public interface, built with `PracticeLibrary.inMemory(clock:)` from `Tests/MuseManCoreTests/Support/TestLibrary.swift`. Act as the user would and check what they would observe: what's in the Library, a Part's Status, Practice Next contents and order, what remains after a deletion. Move time with `TestClock.advance(days:)`; FSRS is tested through this seam.

- Catches: domain rules, scheduling, deletion rules, what survives a save.
- Misses: how a screen shows the result, CloudKit sync, Apple Music lookups.

## Seam 2: what a screen shows

A small value type or static function that takes plain values (Songs, a setting) and decides what a screen shows, tested directly. Examples: `CoverGridLayout` in `Screens/Library/CoverGrid.swift` (which covers go in which tiles) and `Destination.shown(isPracticeNextOn:)` in `Shell/Destination.swift` (which sidebar items appear). When a screen holds a rule worth testing, extract it into such a type beside the view and test that.

- Catches: display rules that branch on data, such as counts, order and visibility.
- Misses: layout, spacing, styling, and whether the view uses the type; check those on screen with the `mac-app` skill.

## Visual only

A ticket ending `Verification: visual only (mac-app)` (see `issue-tracker.md`) is layout only: write no unit tests, verify it with the `mac-app` skill and quote the screenshot paths.
