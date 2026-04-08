---
name: obsigen
description: |
  Use this skill when the user wants to create or update an Obsidian plugin from a natural-language request. It decomposes the request, scaffolds a plugin from the local obsikit template, implements the MVP feature set, and verifies the result against a live Obsidian instance.
---

# Obsigen Orchestrator

Generate and update Obsidian plugins from natural language.

## Capabilities

Read each sub-file from `${CLAUDE_SKILL_DIR}/` when you reach its pipeline stage.

| File | Purpose | When to read |
|---|---|---|
| `decomposer.md` | Scope, risks, verification criteria | Pipeline start |
| `scaffold.md` | Scaffold plugin from local `obsikit` template | After decomposition |
| `task-execution.md` | Build, verify, and fix loop | Before first implementation step |
| `obsidian-quirks.md` | Obsidian lifecycle, API, and release traps | Before changing scaffolded code |
| *(obs-api skill)* | Obsidian class API lookup | When unsure about Obsidian API details |

## MVP scope

This skill currently targets the narrow MVP flow only:

- one plugin
- one command
- one sidebar or custom view
- one small unit of vault interaction

If the user request is broader than that, reduce it to the smallest end-to-end slice that proves the workflow and record the deferred work in `PLAN.md`.

## Pipeline

```text
User request
    |
    +- Check for PLAN.md / STRUCTURE.md / MEMORY.md
    |   +- If present: resume from those files
    |   +- If absent: continue with fresh pipeline
    |
    +- Read decomposer.md
    +- Write PLAN.md
    |
    +- Read scaffold.md
    +- Scaffold from .obsigen/templates/obsikit/
    +- Write STRUCTURE.md and MEMORY.md
    |
    +- Read obsidian-quirks.md
    +- Read task-execution.md
    +- Implement the MVP slice
    +- Build and verify against available Obsidian tooling
    |
    +- Update PLAN.md / MEMORY.md as work progresses
    |
    +- Summarize the working plugin and any deferred scope
```

## Required working files

Keep important state in files so the run is resumable:

- `PLAN.md` — scope, risks, task status, verification criteria
- `STRUCTURE.md` — scaffold layout, naming, and architecture decisions
- `MEMORY.md` — discoveries, failures, workarounds, verification notes

If any of these are missing, create them from the canonical templates in:

- `${CLAUDE_SKILL_DIR}/templates/PLAN.md`
- `${CLAUDE_SKILL_DIR}/templates/STRUCTURE.md`
- `${CLAUDE_SKILL_DIR}/templates/MEMORY.md`

Resume rule:

- if these files already exist, read them first and continue from the recorded state instead of replanning from scratch

## Verification model

Use the local `obsikit` tooling as the verification base.

Default runtime assumption:

- Obsidian is running locally on the host against a dev vault
- the official Obsidian CLI talks to that host app
- the bridge, if enabled, comes from that same local plugin instance
- Docker is a separate e2e verification path, not the normal development target

Start each verification pass by calling:

- `obsidian_get_capabilities`

Then use the best available tools:

- CLI-backed tools for reload, commands, errors, console, DOM, screenshots, and eval
- bridge-backed tools for plugin state, active view/file, and current vault/file operations

Do not assume all tools are always available. Branch based on reported capabilities.

Backend policy:

- local host workflow: `auto` is expected when CLI and bridge point at the same instance
- Docker verification workflow: prefer bridge-only tooling
- do not assume one MCP session should mix host CLI with a Docker bridge

## Obsidian API Lookup

When you need to look up an Obsidian class API (methods, properties, events), use `Skill(skill="obs-api")` with your query. This runs in a separate context to avoid loading API docs into the main pipeline.

Be specific about what you need:
- **Targeted query** — ask for specific methods/events: `"Vault: methods for reading and modifying files"`
- **Full API** — only request when you need to survey the entire class: `"full API for Workspace"`

Examples:
- Skill(skill="obs-api") "Plugin: how to register commands and views"
- Skill(skill="obs-api") "full API for MetadataCache"
- Skill(skill="obs-api") "which class handles file creation and deletion?"
- Skill(skill="obs-api") "Editor: methods for getting and replacing selections"
- Skill(skill="obs-api") "common patterns for settings tabs"

## Guardrails

- Always scaffold from `.obsigen/templates/obsikit/` rather than inventing a plugin layout from scratch.
- Keep the first generated plugin intentionally small.
- Do not expand into settings tabs, CodeMirror extensions, mobile UX, or multi-view plugins unless the user explicitly narrows the task to one of those and the MVP path is already working.
- Treat `obsidian-quirks.md` as mandatory before modifying plugin lifecycle or view behavior.
