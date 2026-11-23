# Coding standards

Judgement calls for review. Mechanical rules live in `.swiftlint.yml`; conventions live in `CLAUDE.md`.

## Same action, same words

An action that appears in more than one place uses the same label and SF Symbol everywhere. For each new button or menu item, search for an existing one doing the same thing and match it: importing audio is `Import Audio…` with `square.and.arrow.down` (`AddRecordingMenu`).

## Shared components spread

A change to a shared view (anything in `Theme/`, or any view with more than one call site) changes every screen that uses it. List each other call site in the review, and flag every screen the request didn't name, so the user decides between the change spreading and a variant.

## Named layout values

A size, spacing or breakpoint that carries meaning (a cover size, the width where a layout switches) or appears in more than one view is a named constant in `Theme`, beside `Theme.margin` and `Theme.readableWidth`. A one-off padding can stay inline.
