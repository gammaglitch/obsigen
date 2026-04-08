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
