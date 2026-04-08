# Obsigen Workspace

This workspace was published from `obsigen`.

Use the published skills in `.claude/skills/` and the pinned scaffold template in `.obsigen/templates/obsikit/` to create an Obsidian plugin from a natural-language request.

When scaffolding a plugin:

1. Start from `.obsigen/templates/obsikit/`.
2. Copy the template into the working plugin files.
3. Rename and adapt the boilerplate to the requested plugin.
4. If `PLAN.md`, `STRUCTURE.md`, or `MEMORY.md` are missing, create them from `.claude/skills/obsigen/templates/`.
5. Track progress in `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md`.
6. Prefer verifying against a local host Obsidian instance first.
7. Use CLI-backed tools for reload, command execution, DOM/CSS inspection, screenshots, eval, and runtime errors when available.
8. Use bridge-backed tools from that same local plugin instance for plugin state, active view/file, and current vault/file helpers.
9. Treat Docker as a separate e2e verification path, not the default development runtime.

Current workflow note:

- After scaffold, there is a local-environment handoff before the build loop can begin.
- The agent can usually write `.env`, install dependencies, and run one-off build commands once the vault path is known.
- The user may still need to complete first-time Obsidian UI setup: open the vault, enable community plugins if needed, and enable the generated plugin.
- After scaffold and local bootstrap, restarting Claude may be necessary so the scaffolded workspace's MCP/tooling context is fully available.
