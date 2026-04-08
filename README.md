# Obsigen

Autonomous Obsidian plugin development pipeline, powered by Claude Code skills.

`obsigen` is a meta-repo. It does not start by generating a full plugin project in place. Instead, it publishes a small Claude workspace that contains:

- the `obsigen` skills
- a `CLAUDE.md` workflow file
- a pinned `obsikit` scaffold template under `.obsigen/templates/obsikit/`

The actual plugin project only appears after the `obsigen` skill runs the scaffold stage.

## Mental model

There are three distinct phases:

1. Publish a Claude workspace
   This gives you a bare working directory with skills and the hidden scaffold template.
2. Scaffold a plugin project
   The agent copies `.obsigen/templates/obsikit/` into the workspace root, renames it, and writes `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md`.
3. Run the local Obsidian development loop
   After scaffold, the workspace becomes a normal Obsidian plugin repo with `package.json`, `src/`, `public/manifest.json`, `.env.example`, and MCP tooling.

If you stop after step 1, the workspace will look bare. That is expected.

## Prerequisites

- Obsidian installed locally
- Obsidian CLI installed and enabled in your local Obsidian setup
- `obsidian version` should work on your machine
- Claude Code installed
- Node.js 22+
- pnpm

Recommended runtime model:

- primary development loop: local host Obsidian
- CLI and bridge should point at that same local Obsidian instance
- Docker is separate e2e verification infrastructure, not the default first-run path

## First-time flow

### 1. Publish a workspace

```bash
bash publish.sh ../my-obsidian-plugin-1
cd ../my-obsidian-plugin-1
```

At this point the workspace is supposed to contain only:

- `.claude/skills/`
- `CLAUDE.md`
- `.obsigen/templates/obsikit/`

It is not a plugin repo yet.

### 2. Start Claude in the published workspace

```bash
claude
```

Then give it a concrete request, for example:

> Create a plugin with a sidebar that lists markdown files and a command that appends a line to the active note.

The expected pipeline is:

1. Write `PLAN.md`
2. Copy `.obsigen/templates/obsikit/` into the workspace root
3. Rename the scaffold to the chosen plugin identity
4. Write `STRUCTURE.md` and `MEMORY.md`
5. Stop at an environment-ready handoff
6. Continue into implementation only after the local dev environment is ready

Only after scaffold should you expect files like:

- `package.json`
- `.env.example`
- `public/manifest.json`
- `src/`
- `mcp/`

### 3. Prepare a local dev vault

Create or choose a vault for local development:

```bash
mkdir -p ~/my-obsidian-plugin-1-vault
```

Open that vault in your local Obsidian app.

### 4. After scaffold, configure the plugin repo

Once the agent has scaffolded the plugin into the workspace root:

```bash
cp .env.example .env
pnpm install
```

Set `OBSIDIAN_PATH` in `.env` to your local dev vault:

```bash
OBSIDIAN_PATH=/home/you/my-obsidian-plugin-1-vault
```

If you want bridge-backed MCP tools too, keep these enabled:

```bash
VITE_OBSIDIAN_DEBUG_BRIDGE=1
VITE_OBSIDIAN_DEBUG_BRIDGE_HOST=127.0.0.1
VITE_OBSIDIAN_DEBUG_BRIDGE_PORT=27124
```

The agent can write `.env` once it knows the vault path. If the vault path is not already known, this is a real handoff point where the user needs to provide it.

### 5. Run the local build loop

```bash
pnpm dev
```

This builds the plugin directly into:

```text
$OBSIDIAN_PATH/.obsidian/plugins/<manifest.id>/
```

The plugin code is built into the vault plugin folder. It does not run from the workspace root directly.

The agent can run `pnpm install` and one-off build commands. `pnpm dev` is a long-running watch process, so treat that as part of the local environment bootstrap rather than a pure one-shot pipeline step.

### 6. Prepare local Obsidian

In your local Obsidian app:

1. Open the dev vault from `OBSIDIAN_PATH`
2. Enable community plugins if needed
3. Enable the generated plugin
4. Make sure the Obsidian CLI is available for that running app instance

Useful checks from your shell:

```bash
obsidian version
obsidian vault info=name
```

If the bridge is enabled and the plugin is loaded, it should respond on:

```text
http://127.0.0.1:27124
```

The agent cannot reliably do the first-time Obsidian UI setup itself. This is the main manual bootstrap point:

- open the vault
- enable community plugins if needed
- enable the generated plugin the first time
- confirm the CLI is available for the running app instance

After that, the agent can usually stay in control via build, CLI reload, bridge checks, and runtime verification.

### 7. Let the agent verify and iterate

In the normal local-host workflow:

- CLI-backed tools handle reload, command execution, errors, DOM/CSS inspection, screenshots, and eval
- bridge-backed tools handle plugin state, active file/view, and vault file helpers

Both are expected to target the same local Obsidian instance.

## Environment-ready handoff

There is currently a real handoff between scaffold and implementation.

Scaffold phase:

- Claude creates `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md`
- Claude copies the hidden `obsikit` template into the workspace root
- the workspace becomes a real plugin repo

Environment-ready phase:

- `.env` exists and points at the correct local vault
- dependencies are installed
- `pnpm dev` or another build loop is running
- Obsidian is open on that vault
- the generated plugin is enabled
- the CLI works
- the bridge responds if enabled

Only after that should the implementation and verification loop continue.

## Claude restart note

There is another practical boundary after scaffold.

Before scaffold, the published workspace does not yet have the plugin repo files at the root, so root-level MCP setup for the scaffolded plugin is not present yet.

In practice, the cleanest flow is often:

1. start Claude in the published workspace
2. let it scaffold the plugin repo
3. prepare the local environment
4. restart Claude in the scaffolded workspace
5. continue with implementation and verification using the now-available MCP/tooling context

## What `publish.sh` does

`publish.sh` publishes an agent workspace, not a finished plugin repo.

It currently copies:

- `.claude/skills/`
- `CLAUDE.md`
- `.obsigen/templates/obsikit/`

That is why the published directory looks minimal at first.

## What the agent is supposed to create

During scaffold, the `obsigen` skill should create:

- `PLAN.md`
- `STRUCTURE.md`
- `MEMORY.md`
- the plugin repo files copied from `.obsigen/templates/obsikit/`

The plugin repo should then behave like a normal `obsikit`-based plugin project.

## Verification model

Primary path:

- local host Obsidian
- host Obsidian CLI
- optional host bridge from the same plugin instance

Secondary path:

- Dockerized e2e verification

Do not treat Docker as the default first-run flow.

## Current limitation

The documentation is now explicit about the intended flow, but the workflow still depends on the `obsigen` skill actually performing the scaffold step correctly. If the agent has not scaffolded the plugin into the workspace root yet, commands like `pnpm install`, `pnpm dev`, or `cp .env.example .env` will not work because the repo is still only a published control workspace.
