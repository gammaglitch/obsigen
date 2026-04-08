# Scaffold

Create the initial plugin workspace from the local `obsikit` template.

## Goal

Produce a compilable Obsidian plugin skeleton based on:

- `.obsigen/templates/obsikit/`

Do not invent the project structure from scratch.

## Required outputs

- scaffolded plugin files in the working directory
- `STRUCTURE.md`
- initial `MEMORY.md`

If `STRUCTURE.md` or `MEMORY.md` does not exist yet, start from:

- `${CLAUDE_SKILL_DIR}/templates/STRUCTURE.md`
- `${CLAUDE_SKILL_DIR}/templates/MEMORY.md`

Replace every `<...>` placeholder before leaving the scaffold stage.

## Scaffold steps

1. Read `PLAN.md` and take the plugin `Display name`, `Plugin id`, and `Platform classification` from there. Do not invent a second identity here.
2. Copy the local template from `.obsigen/templates/obsikit/` into the working plugin workspace.
3. Update plugin identity in these files at minimum:
   - `public/manifest.json`
   - `package.json`
   - `src/obsidian/constants.ts`
   - `src/main.ts`
4. Replace the example view seam:
   - rename `src/components/ExampleView.tsx` to `src/components/PluginView.tsx`
   - update `src/ViewWrapper.tsx` to import and render `PluginView`
5. Rename the main classes in `src/main.ts`:
   - `ObsikitPlugin` -> `<PascalCasePluginName>Plugin`
   - `ObsikitView` -> `<PascalCasePluginName>View`
6. Update `PLUGIN_VIEW_TYPE` to `<plugin-id>-view` and `PLUGIN_VIEW_NAME` to the chosen display name.
7. Keep the `obsikit` runtime, harness, and MCP tooling intact unless the requested feature requires a specific change.
8. Preserve the plugin shell and verification infrastructure.

## Files that should remain intact during scaffold

Do not delete or redesign these during scaffold:

- `mcp/`
- `scripts/`
- `tests/e2e/`
- `src/obsidian/testBridge.ts`
- `src/obsidian/view.ts`
- `src/obsidian/VaultSync.tsx`
- `docker-compose.dev.yml`
- `docker-compose.e2e.yml`

## Naming rules

- plugin `id` must be deterministic
- plugin `id` must not contain `obsidian`
- plugin folder name should match plugin `id`
- `name`, `description`, `version`, `author`, `minAppVersion`, and `isDesktopOnly` must remain valid

Use these deterministic transforms:

- display name -> `PascalCasePluginName` for class names
- plugin id -> `PLUGIN_VIEW_TYPE` as `<plugin-id>-view`
- display name -> `PLUGIN_VIEW_NAME`

If the request does not include a good display name, write one in `PLAN.md` first and then scaffold from that.

## What `STRUCTURE.md` should record

Use the canonical template at `${CLAUDE_SKILL_DIR}/templates/STRUCTURE.md`.

Record:

- chosen plugin name and ID
- whether the plugin is `cross-platform safe` or `desktop-only`
- which files are core shell vs feature-specific
- where the command lives
- where the view lives
- where the vault interaction lives
- the rename map actually applied during scaffold

## What `MEMORY.md` should record initially

Use the canonical template at `${CLAUDE_SKILL_DIR}/templates/MEMORY.md`.

Write:

- scaffold source path
- naming decisions
- platform classification
- any quirks already known from the request
- the exact files changed during scaffold
- `Stage: scaffold` and the next implementation step

## Current MVP constraint

Do not try to redesign the whole template during scaffold.

The scaffold step should get the project to:

- valid manifest
- valid plugin identity
- preserved harness/tooling
- `PluginView.tsx` as the feature view seam
- clear seams for the command and vault interaction

Implementation comes later in `task-execution.md`.
