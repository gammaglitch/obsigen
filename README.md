# Obsigen

Autonomous Obsidian plugin development pipeline, powered by Claude Code skills.

Describe a plugin in plain language. Obsigen decomposes it, scaffolds the project, implements the code, and verifies it against a live Obsidian instance — all without human intervention.

Built on [obsikit](../obsikit), which provides:

- a local host-Obsidian development loop with the official CLI and optional in-plugin bridge against the same running app instance
- a Dockerized e2e harness for isolated verification
- a unified MCP server that can use both capability sources without making `obsigen` depend on Docker as the default runtime

## Prerequisites

- [Obsidian](https://obsidian.md/) installed locally
- [Obsidian CLI](https://obsidian.md/cli) installed and working (`obsidian version` should respond)
- [Claude Code](https://claude.com/claude-code) installed
- Node.js 22+ and pnpm

## Setup

### 1. Publish a workspace

```bash
bash publish.sh ~/my-plugin
```

This creates a self-contained workspace with skills, CLAUDE.md, and the obsikit scaffold template.

### 2. Prepare the dev vault

The published workspace needs a vault for Obsidian to run against. You can use an existing vault or create a fresh one:

```bash
mkdir -p ~/my-plugin-vault
```

### 3. Set up the plugin build

```bash
cd ~/my-plugin
# After scaffolding, the plugin will be buildable:
cp .env.example .env
# Edit .env to set OBSIDIAN_PATH to your dev vault:
#   OBSIDIAN_PATH=/home/you/my-plugin-vault
pnpm install
pnpm dev
```

### 4. Enable the Obsidian CLI

Make sure Obsidian is running and the CLI can reach it:

```bash
obsidian version     # should print the app version
obsidian vault info=name  # should print the active vault name
```

If these don't work, check that Obsidian is running and the CLI is installed. The CLI communicates with the running Obsidian instance via IPC.

### 5. Enable the bridge (optional but recommended)

The bridge gives the agent access to plugin state, vault file operations, and active view information that the CLI doesn't expose.

Add these to your `.env` before building:

```
VITE_OBSIDIAN_DEBUG_BRIDGE=1
VITE_OBSIDIAN_DEBUG_BRIDGE_HOST=127.0.0.1
VITE_OBSIDIAN_DEBUG_BRIDGE_PORT=27124
```

Rebuild with `pnpm dev`. When Obsidian loads the plugin, the bridge listens on `http://127.0.0.1:27124`.

### 6. Run the pipeline

```bash
cd ~/my-plugin
claude
```

Then describe the plugin you want:

> Create a plugin with a sidebar that lists markdown files and a command that appends a line to the active note.

The agent will decompose the request, scaffold from the obsikit template, implement the feature, and verify it against your running Obsidian instance.

## How it works

The pipeline has four stages:

1. **Decompose** — narrows the request to a minimal MVP slice, writes `PLAN.md`
2. **Scaffold** — copies the obsikit template, renames to the plugin identity, writes `STRUCTURE.md` and `MEMORY.md`
3. **Implement** — builds the feature in a build/reload/verify loop
4. **Verify** — confirms command, view, and vault behavior using CLI and bridge tools

Progress is tracked in `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md` so the pipeline can resume if interrupted.

## Verification model

The agent uses obsikit's unified MCP server, which assembles tools from:

- **CLI-backed**: plugin reload, command execution, DOM/CSS queries, screenshots, eval, runtime errors
- **Bridge-backed**: plugin state, active file/view, vault file operations

Both should point at the same local Obsidian instance. Docker is a separate e2e verification path.

## Skills

| Skill | Purpose |
|---|---|
| `obsigen` | Main orchestrator — decomposes, scaffolds, implements, verifies |
| `obs-api` | Obsidian API lookup — vendored per-class docs from obsidian.d.ts |
