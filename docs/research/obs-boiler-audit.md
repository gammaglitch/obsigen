# obsikit Audit

Current state of the Obsidian plugin boilerplate as of 2026-04-07. Source: `../obsikit/`.

## What it is

An opinionated Obsidian plugin boilerplate with Preact + Jotai + Tailwind, designed for LLM-assisted development. Ships with a working example feature (file browser + append), a Dockerized Obsidian e2e harness, an in-plugin HTTP bridge, and an MCP server that wraps the bridge for Claude Code.

## Stack

- **UI:** Preact (not React — smaller, same API)
- **State:** Jotai (atomic state, no providers)
- **Styling:** Tailwind CSS
- **Build:** Vite
- **Tests:** Jest (unit), Playwright (e2e)
- **Runtime:** Obsidian plugin API (TypeScript)

## Infrastructure components

### Docker e2e harness

**Files:** `Dockerfile.e2e`, `docker-compose.e2e.yml`, `scripts/prepare-e2e-vault.mjs`, `scripts/build-e2e-plugin.mjs`

Runs Obsidian inside Docker with Playwright Electron support:

1. Base image: `mcr.microsoft.com/playwright:v1.52.0-jammy` with FUSE, Xvfb, xdg-utils added
2. Obsidian AppImage mounted read-only, extracted at runtime with `--appimage-extract`
3. Electron fuse `EnableNodeCliInspectArguments` flipped with `@electron/fuses` (required for Playwright's debugging pipe)
4. Xvfb provides a virtual display (`:99`, 1280x1024x24)
5. Vault pre-registered in `obsidian.json` so Obsidian opens it directly (skips vault picker)
6. Trust dialog dismissed automatically

Two compose files:
- `docker-compose.e2e.yml` — run tests and exit (CI mode, `--frozen-lockfile`)
- `docker-compose.dev.yml` — long-running, bridge enabled, healthcheck on `/health`, port forwarded

### HTTP bridge (`testBridge.ts`)

An HTTP server embedded in the plugin, enabled via `VITE_OBSIDIAN_DEBUG_BRIDGE=1`. Runs inside the Obsidian Electron process using Node's `http` module (accessed via `require('node:http')` through Obsidian's Node integration).

**Endpoints:**
- `GET /health` — status, method list, auth requirement
- `POST /call` — JSON-RPC style dispatch (`{ method, params }`)

**Methods (16 total):**

| Method | What it does |
|---|---|
| `ping` | Connectivity check |
| `describe` | List available methods |
| `getPluginState` | Vault name, active file, open views, recent errors |
| `openPluginView` | Open/reveal the plugin sidebar |
| `listFiles` | All markdown files |
| `listFolders` | All folders |
| `readVaultFile` | Read file content |
| `writeVaultFile` | Overwrite file content |
| `createFile` | Create new file |
| `deleteFile` | Move to trash |
| `appendToFile` | Append line to file |
| `searchVault` | Case-insensitive filename + content search |
| `getFileMetadata` | Frontmatter, tags, size, timestamps |
| `getActiveFile` | Currently active file |
| `getActiveViewInfo` | Active view type, title, associated file |
| `getRecentErrors` | Last 25 uncaught errors (window.onerror + unhandledrejection) |

**Security:** Optional bearer token via `VITE_OBSIDIAN_DEBUG_BRIDGE_TOKEN`. CORS headers allow `*` (dev-only tool). Binds to `127.0.0.1` by default. 1 MiB request body limit.

**Lifecycle:** Started in `main.ts` `onload()`, stopped in `onunload()`. Registered with `plugin.register()` for cleanup.

### MCP server (`mcp/bridge-server.mjs`)

Wraps the HTTP bridge as an MCP tool server for Claude Code. Uses `@modelcontextprotocol/sdk` with stdio transport. Each bridge method becomes an `obsidian_*` tool with Zod-validated parameters.

Configured via `.mcp.json` at repo root — Claude Code picks it up automatically. Environment: `OBSIDIAN_BRIDGE_URL` and optional `OBSIDIAN_BRIDGE_TOKEN`.

### CDP trust dismissal (`scripts/cdp-dismiss-trust.mjs`)

Standalone script that connects to Obsidian via Chrome DevTools Protocol (`--remote-debugging-port=9222`), waits for the "Trust author and enable plugins" button, clicks it, and presses Escape. Used by the dev harness to avoid interactive Playwright involvement. Polls CDP endpoint for up to 30s, waits 15s for the dialog.

### E2e smoke test

`tests/e2e/smoke.spec.ts` — launches Obsidian via Playwright Electron, dismisses trust dialog, waits for `data-testid="plugin-root"`, asserts the sidebar and file list are visible, checks for zero console/page errors.

Fixtures: `tests/e2e/fixtures/vault/` with `example.md` and pre-configured `.obsidian/` (app.json, community-plugins.json, core-plugins.json).

## Plugin architecture

### Core shell (reusable across plugins)

- `src/main.ts` — plugin lifecycle, registers view, starts bridge
- `src/ViewWrapper.tsx` — Preact app root mounting
- `src/obsidian/constants.ts` — view type, name, icon identifiers
- `src/obsidian/view.ts` — open/reveal plugin view helper
- `src/obsidian/events.ts` — vault and metadata cache listener registration
- `src/obsidian/VaultSync.tsx` — bridges vault events into Jotai state
- `src/store/atoms/files.tsx` — plugin reference and file data atoms

### Example feature (replace to build your own plugin)

- `src/components/ExampleView.tsx` — file list sidebar + content display + append input
- `src/helpers/lines.ts` — pure append/parse logic (with `lines.test.ts`)
- `src/helpers/files/util.ts` — vault read/write via `vault.modify()`

### Edit seams documented in AGENTS.md

- `src/helpers/` — safe, pure logic
- `src/helpers/files/util.ts` — vault operations
- `src/store/atoms/files.tsx` — shared state
- `src/components/` — UI
- `src/main.ts`, `src/obsidian/` — modify with care

## Development history (from docs/log.md)

- **2026-01** — started as task manager plugin, added parse/serialize helpers, tests, architecture docs
- **2026-02** — stripped to minimal boilerplate, extracted generic shell into `src/obsidian/`, replaced context pattern with VaultSync
- **2026-03** — added Dockerized e2e scaffold with Playwright Electron, added HTTP bridge, added Docker dev harness
- **2026-04** — extended bridge API (create, delete, search, folders, metadata), added MCP server, fixed Docker issues (pnpm 10 compat, Electron fuses, CDP trust dismissal)

## What's ready for obsigen to build on

### Ready now

- **Docker Obsidian runtime** — plugin loads, runs, and is inspectable in a headless container
- **Two-way live bridge** — 16 methods covering vault CRUD, workspace state, error capture
- **MCP integration** — Claude Code can call vault operations as native tools
- **E2e infrastructure** — Playwright can launch, screenshot, and assert against the running plugin
- **Clean boilerplate separation** — core shell vs feature code is explicit

### Gaps to address

- **No screenshot capture in the verification loop** — e2e has Playwright screenshots, but there's no skill or script that captures and feeds them to a vision model as part of an iterative build cycle
- **No hot-reload trigger** — the bridge can't tell Obsidian to reload the plugin after a rebuild. Currently requires manual reload or restart. A `reloadPlugin` bridge method would close this gap.
- **Bridge only exposes vault and workspace** — no access to plugin settings, commands, hotkeys, or the DOM. Expanding the bridge API would make more checks programmatic vs visual.
- **No error categorization** — `getRecentErrors` returns raw strings. Structured error objects (stack, source, timestamp) would help the LLM diagnose issues.
- **MCP server is read-heavy** — most tools query state. Missing: `obsidian_execute_command` (run an Obsidian command by ID), `obsidian_take_screenshot` (capture viewport), `obsidian_reload_plugin`.
