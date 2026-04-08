# Obsidian Plugin Guidelines And Gotchas

Research snapshot for `obsigen` as of 2026-04-08.

This note captures the official constraints and traps most likely to break an autonomous plugin-generation workflow.

## Why this matters for obsigen

These items should eventually become:

- `obsidian-quirks.md` in the skill set
- validation checks in the scaffold and execution loop
- heuristics in the verifier

## Manifest and identity rules

Official manifest constraints that matter immediately:

- plugin `id` is required
- plugin `id` cannot contain `obsidian`
- plugin folder name should match the plugin `id`
- `version`, `name`, `description`, `author`, `minAppVersion`, and `isDesktopOnly` are required
- `isDesktopOnly` must reflect actual use of Node or Electron APIs

This means `obsigen` needs a deterministic plugin naming pass during scaffold, not a loose placeholder rename.

## File and vault APIs

The official guidance strongly prefers higher-level Obsidian APIs over low-level file access:

- prefer `Vault.process()` over separate `read()` plus `modify()`
- prefer `FileManager.processFrontMatter()` for frontmatter edits
- prefer `trash()` or `trashFile()` over hard delete flows
- prefer `Vault` APIs over direct `Adapter` access when possible
- use `normalizePath()` for user-provided paths

This is a direct challenge to parts of the current `obsikit` example code, which still uses direct read/modify flows. For `obsigen`, that means the scaffold source is useful, but generated feature code should move toward the official safer patterns.

## Runtime and compatibility rules

Official compatibility guidance relevant to MVP:

- if mobile support matters, do not assume `FileSystemAdapter`
- if desktop-only features are used, gate Node or Electron-specific code carefully
- use `Platform` instead of `process.platform`
- prefer `requestUrl` over `fetch` or `axios.get`
- avoid top-level use of Node modules when `isDesktopOnly` is `false`

This suggests `obsigen` should classify plugin requests early as:

- desktop-only
- cross-platform safe

That classification should drive manifest generation and implementation choices.

## Workspace and view gotchas

Two official performance and correctness traps are especially important:

- plugin startup work should be minimized in `onload()`
- heavy startup work and some event registration should move to `workspace.onLayoutReady()`

There is also a newer workspace/view constraint:

- as of Obsidian `1.7.2`, views may be `DeferredView` instances until revealed or explicitly loaded
- code that assumes `leaf.view` is already the final custom view can break
- use `instanceof` checks before casting custom views
- reveal the leaf or explicitly load the deferred view before operating on it

This is highly relevant to `obsikit` and to any generated sidebar plugin. `obsigen` should treat deferred-view safety as a first-class scaffold rule, not a later bugfix.

## Performance guidance

Official load-time guidance for plugins:

- keep `onload()` lightweight
- make production builds small and minified
- avoid expensive work in custom view constructors
- be careful with vault event handlers during startup, because vault initialization emits events too

This suggests `obsigen` should avoid generating plugins that eagerly scan the entire vault during startup unless the feature strictly needs it.

## Release-quality coding checklist items worth encoding

The official self-critique checklist highlights several rules that should become generator defaults:

- do not prefix command names with plugin name or plugin ID
- do not ship placeholder names
- do not use the global `app` instance when `this.app` is available
- do not hardcode styling into JS when CSS is the right place
- do not keep unnecessary `console.log` statements
- do use a lockfile
- do disclose network use, payments, telemetry, and external data access in README files when relevant

## Implications for obsigen

The first-generation skill set should encode checks for:

- manifest correctness
- platform classification
- safe file mutation patterns
- deferred-view-safe access patterns
- lightweight startup behavior
- release-ready naming and command text

## Sources

- Obsidian Developer Docs: Manifest
  https://docs.obsidian.md/Reference/Manifest
- Obsidian Developer Docs: Vault
  https://docs.obsidian.md/Plugins/Vault
- Obsidian Developer Docs: Optimize plugin load time
  https://docs.obsidian.md/plugins/guides/load-time
- Obsidian Developer Docs: Defer views
  https://docs.obsidian.md/plugins/guides/defer-views
- Obsidian Developer Docs: Plugin self-critique checklist
  https://docs.obsidian.md/oo/plugin
