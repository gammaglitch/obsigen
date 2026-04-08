# Obsidian Plugin Development Basics

Research snapshot for `obsigen` as of 2026-04-08.

This note captures the minimum official mental model for Obsidian plugin development, with emphasis on what an autonomous plugin-generation pipeline needs to know.

## Why this matters for obsigen

`obsigen` should not invent a plugin structure. It should scaffold from the shape Obsidian already expects, then adapt it to the requested feature.

## Official plugin shape

From the official sample plugin and API docs, an Obsidian community plugin is centered around:

- `manifest.json`
- `main.js`
- optional `styles.css`
- a default exported class that extends `Plugin`

The important runtime surfaces exposed to plugins are:

- `App`
- `Vault`
- `Workspace`
- `MetadataCache`

These are the main abstractions `obsigen` should optimize around when decomposing user requests.

## Standard development loop

The official "build a plugin" flow is:

1. Start from the official sample plugin or equivalent template.
2. Install dependencies and run a watch build.
3. Load the plugin into a dedicated development vault.
4. Reload Obsidian or reload the plugin after code changes.
5. Enable the plugin in Community Plugins and verify behavior.

Two details matter for automation:

- Plugin development should happen in a dedicated test vault, not a user's real vault.
- Changes to `manifest.json` require an app restart or equivalent reload path, because plugin metadata is not treated like normal source code changes.

## Minimal feature set shown by official examples

The official sample plugin demonstrates the core feature categories an MVP scaffold should support:

- ribbon icon or command registration
- modal or view interaction
- settings tab
- event registration
- interval registration
- persistent plugin data via plugin APIs

For `obsigen`, this supports the decision to make the first generated plugin intentionally narrow:

- one command
- one sidebar or custom view
- one simple vault interaction

## Implications for scaffold design

The scaffold step should guarantee:

- a valid `manifest.json`
- a compiled plugin entry point
- a `Plugin` subclass with `onload()` and `onunload()`
- a clear place for command registration
- a clear place for view registration
- a clear place for settings and persisted plugin data

This aligns with using `obsikit` as the base scaffold, because `obsikit` already provides a working plugin shell and verification harness.

## Implications for the execution loop

`obsigen` should model the plugin execution loop as:

1. scaffold from `obsikit`
2. implement feature code
3. rebuild
4. reload plugin or app
5. verify command, view, and runtime state
6. fix and repeat

The official docs and sample plugin both reinforce that "reload after change" is a first-class part of plugin development rather than an optional convenience.

## Sources

- Obsidian Developer Docs: Home
  https://docs.obsidian.md/Home
- Obsidian Developer Docs: Build a plugin
  https://docs.obsidian.md/Plugins/Getting%20started/Build%20a%20plugin
- Obsidian sample plugin README
  https://github.com/obsidianmd/obsidian-sample-plugin
- Obsidian API README
  https://github.com/obsidianmd/obsidian-api
