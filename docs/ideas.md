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

## Eval-based test harness

Godogen has a test-harness skill that generates SceneTree scripts to exercise games — simulating input, asserting positions/state, and capturing frames. Obsigen doesn't need this for MVP because obsikit's MCP tools (reload, command exec, DOM query, screenshot) serve as the test harness directly.

When it makes sense: if plugins require multi-step interaction sequences that can't be verified with single MCP calls. For example: open modal → type in field → click submit → verify vault file was created. At that point, an `obsidian_eval`-based approach could work — JavaScript snippets executed inside Obsidian that simulate user actions and return assertions. This would be the Obsidian equivalent of godogen's SceneTree test scripts.

## Multi-view plugins

The MVP pipeline targets single-command, single-view plugins. Extending to multi-view (e.g., sidebar + modal + settings tab interacting) would need decomposer changes to handle view coordination and task-execution changes to verify cross-view state.
