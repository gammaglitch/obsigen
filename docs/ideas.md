# Ideas

Future enhancements to revisit when the MVP pipeline is proven.

## Visual QA skill (Gemini-backed)

A forked-context skill using Gemini Flash for screenshot analysis, modeled on godogen's visual-qa. Would provide unbiased visual assessment separate from the orchestrator's own analysis.

When it makes sense: if obsigen starts handling complex UI — custom CSS themes, canvas-based rendering, drag-and-drop layouts, or any plugin where DOM inspection alone can't verify correctness.

For now, the orchestrator handles visual verification directly via screenshot + DOM query + CSS inspection from obsikit's MCP tools.

## Obsidian CLI integration

The official `obsidian-cli` (from obsidian-skills) encodes a plugin-dev loop: reload, inspect errors, verify via DOM, check console. Currently obsikit covers this via its Docker bridge + MCP server, but if the official CLI matures, it could replace or supplement the bridge for local (non-Docker) development.

## Template versioning

Pin scaffold templates to specific Obsidian API versions. When obsidocs tags accumulate, the scaffold step could auto-select a template variant matching the target API version.

## Multi-view plugins

The MVP pipeline targets single-command, single-view plugins. Extending to multi-view (e.g., sidebar + modal + settings tab interacting) would need decomposer changes to handle view coordination and task-execution changes to verify cross-view state.
