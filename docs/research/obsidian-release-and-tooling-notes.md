# Obsidian Release And Tooling Notes

Research snapshot for `obsigen` as of 2026-04-08.

This note focuses on the official release path and the developer tooling that matters to an automated plugin workflow.

## Release path for community plugins

The official submission flow requires:

- a public GitHub repository
- `README.md` in repo root
- `LICENSE` in repo root
- `manifest.json` in repo root
- a GitHub release whose tag exactly matches `manifest.json` version
- release assets attached as binaries:
  - `main.js`
  - `manifest.json`
  - optional `styles.css`

Only the initial version needs submission to the official plugin list. After that, updates ship through new GitHub releases.

## Versioning expectations

The official sample plugin also expects:

- semantic versioning in `manifest.json`
- `versions.json` mapping plugin versions to minimum compatible Obsidian versions
- version bumps kept consistent between plugin metadata and package metadata

This is not strictly needed for the first `obsigen` MVP, but it does affect how scaffolded projects should be structured if they are meant to graduate into publishable community plugins.

## Important release-quality rules

The official guidance and checklists imply:

- `main.js` should be a release artifact, not a committed source file in the repo by default
- command names should be user-facing and not redundantly prefixed
- plugin metadata should be cleaned up before release
- release automation eventually needs to understand GitHub releases and attachment generation

## Obsidian CLI is now relevant

The official Obsidian CLI significantly changes the verification story for plugin development:

- it can reload plugins by ID
- it can execute commands by ID
- it can report developer errors
- it can inspect the DOM
- it can take screenshots
- it can execute JavaScript in app context

This matters because the current `obsikit` bridge is not the only viable verification path anymore. The CLI is now an official surface that overlaps with several bridge features we previously thought we had to build ourselves.

## Implications for obsigen

For MVP:

- keep using `obsikit` as the scaffold and current harness
- but plan around a future verifier that can use the official Obsidian CLI where available

For post-MVP:

- consider whether `obsidian plugin:reload`, `command`, `dev:errors`, `dev:screenshot`, and `eval` can replace or reduce custom bridge work
- consider a dual-mode verifier:
  - official CLI path when installed
  - `obsikit` bridge fallback when running in the current Docker harness

## MCP versus CLI direction

The better architecture is not "CLI or MCP".

The better architecture is:

- official CLI as one backend
- MCP as the LLM-facing tool layer

That gives agents typed tools while still aligning the project with official Obsidian tooling.

Just as important, the MCP layer should not pretend that all backends are identical.

The correct model is:

- shared MCP tools for capabilities that genuinely overlap
- backend-specific MCP tools for capabilities unique to the CLI or the custom bridge
- capability reporting so the agent can discover what is available in the current environment

This avoids two failure modes:

- flattening everything to the weakest common denominator
- inventing fake parity between tools that behave differently

## Sources

- Obsidian Developer Docs: Submit your plugin
  https://docs.obsidian.md/Plugins/Releasing/Submit%20your%20plugin
- Obsidian sample plugin README
  https://github.com/obsidianmd/obsidian-sample-plugin
- Obsidian Help: CLI
  https://help.obsidian.md/cli
