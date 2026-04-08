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

## Scaffold steps

1. Copy the local template into the working plugin workspace.
2. Rename the plugin consistently across:
   - `manifest.json`
   - package metadata where relevant
   - plugin constants and display strings
3. Keep the `obsikit` runtime, harness, and MCP tooling intact unless the requested feature requires a specific change.
4. Replace template/example naming with plugin-specific naming.
5. Preserve the plugin shell and verification infrastructure.

## Naming rules

- plugin `id` must be deterministic
- plugin `id` must not contain `obsidian`
- plugin folder name should match plugin `id`
- `name`, `description`, `version`, `author`, `minAppVersion`, and `isDesktopOnly` must remain valid

## What `STRUCTURE.md` should record

Use this structure:

```md
# STRUCTURE

## Plugin identity

## Scaffold base

## Core shell

## Feature files

## Verification surfaces
```

Record:

- chosen plugin name and ID
- whether the plugin is `cross-platform safe` or `desktop-only`
- which files are core shell vs feature-specific
- where the command lives
- where the view lives
- where the vault interaction lives

## What `MEMORY.md` should record initially

Write:

- scaffold source path
- naming decisions
- platform classification
- any quirks already known from the request

## Current MVP constraint

Do not try to redesign the whole template during scaffold.

The scaffold step should get the project to:

- valid manifest
- valid plugin identity
- preserved harness/tooling
- clear seams for the MVP feature

Implementation comes later in `task-execution.md`.
