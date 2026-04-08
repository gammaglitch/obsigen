# Obsidian Quirks

High-value rules for the first `obsigen` MVP.

## Identity and manifest

- plugin `id` is required
- plugin `id` must not contain `obsidian`
- plugin folder name should match plugin `id`
- keep `name`, `description`, `version`, `author`, `minAppVersion`, and `isDesktopOnly` valid

## Platform classification

- if desktop-only features are used, mark the plugin accordingly
- do not assume desktop-only behavior for ordinary vault and UI work
- avoid top-level Node or Electron usage when `isDesktopOnly` is `false`

## Vault and file mutation

- prefer `Vault.process()` over separate read + modify flows when practical
- prefer `FileManager.processFrontMatter()` for frontmatter edits
- prefer trash flows over permanent delete behavior
- use Obsidian APIs over low-level adapter access where possible

## Lifecycle and performance

- keep `onload()` lightweight
- avoid eager whole-vault work unless the feature truly needs it
- be careful with vault events during startup
- use `workspace.onLayoutReady()` for work that depends on the workspace being ready

## Views

- custom views may be deferred until revealed
- do not assume `leaf.view` is already the final concrete custom view
- use safe checks before casting custom views
- reveal or load the view before operating on it

## Release-quality defaults

- do not prefix command names with the plugin name or plugin ID
- do not leave placeholder names behind
- do not use global `app` when `this.app` is available
- do not keep unnecessary `console.log` output
- keep styling in CSS where possible

## Verification implication

When a command or view seems correct in code but fails in practice, suspect:

- deferred view behavior
- reload state
- startup timing
- manifest identity mismatch
