# Godogen Architecture Analysis

Research notes from studying the godogen repo — an autonomous game development pipeline for Godot, built as Claude Code skills.

## What godogen is

A meta-repo that develops and publishes Claude Code skills into target game project folders. It does not contain games — it contains the tools to build them. A user runs `./publish.sh ~/my-game` and gets a self-contained Claude Code workspace with skills, a CLAUDE.md template, and a .gitignore. From there, `/godogen` turns a sentence into a playable Godot game.

## Repo structure

```
skills/
  godogen/           # orchestrator skill — pipeline + all stages
    SKILL.md         # entry point, progressive loading table
    visual-target.md # generate reference screenshot
    decomposer.md    # risk analysis -> PLAN.md
    scaffold.md      # architecture -> STRUCTURE.md + project skeleton
    asset-planner.md # budget-aware asset planning
    asset-gen.md     # image/3D generation CLI reference
    rembg.md         # background removal
    task-execution.md # implementation loop
    quirks.md        # Godot engine traps
    scene-generation.md # scene builder patterns
    test-harness.md  # verification scripts
    capture.md       # screenshot/video capture
    visual-qa.md     # forked VQA invocation
    android-build.md # APK export
    tools/           # Python scripts (asset gen, rembg, tripo3d, etc.)
  godot-api/         # forked skill — API lookup service
    SKILL.md         # context: fork, model: sonnet, agent: Explore
    gdscript.md      # hand-written language reference
    csharp.md        # C# Godot syntax reference
    tools/           # doc converter, bootstrap script
  visual-qa/         # forked skill — visual quality assurance
    SKILL.md         # context: fork
    scripts/         # Gemini/Claude vision prompts + Python driver
game.md              # CLAUDE.md template for game folders
publish.sh           # deploy skills into a target project
PROJECT.md           # detailed writeup of the system
```

## Key architectural patterns

### 1. Meta-repo with publish script

The repo itself is never the working directory for game development. `publish.sh` copies `skills/` into `<target>/.claude/skills/` and `game.md` into `<target>/CLAUDE.md`. The game folder is then self-contained — anyone with Claude Code can open it and run `/godogen`.

### 2. Progressive stage loading

The orchestrator SKILL.md has a table mapping sub-files to pipeline stages. Each sub-file is loaded only when that stage begins, not upfront. This keeps the context window focused during long multi-stage runs.

```
| File               | When to read              |
| visual-target.md   | Pipeline start            |
| decomposer.md      | After visual target       |
| scaffold.md        | After decomposition       |
| task-execution.md  | Before first task         |
| quirks.md          | Before writing code       |
```

### 3. Forked skills for heavy reference material

Two skills run in separate contexts (`context: fork` in SKILL.md frontmatter):

- **godot-api** — 850+ class API docs, runs with Sonnet model and Explore agent. A lookup service that keeps massive docs out of the main orchestrator.
- **visual-qa** — vision model analysis of screenshots. Runs in its own context so vision payloads don't pollute the main window.

The fork mechanism is a Claude Code skill feature: `context: fork` means the skill runs in a separate conversation, and optionally with a different `model:` and `agent:` type.

### 4. Document protocol for resumability

Stages communicate through structured markdown files, not conversation:

- **PLAN.md** — risk tasks, main build scope, verification criteria, task status tracking
- **STRUCTURE.md** — architecture reference (scenes, scripts, signals, build order)
- **ASSETS.md** — asset manifest with art direction, sizes, file paths
- **MEMORY.md** — accumulated discoveries, workarounds, what worked/failed

These files survive context compaction and make the pipeline resumable from any point. If the context window gets compressed, the pipeline reads these files to recover state.

### 5. Risk-first decomposition

The decomposer categorizes features into two buckets:

- **Risk tasks** — features that fail unpredictably (procedural generation, complex physics, custom shaders, animation systems). Each gets isolated implementation and verification.
- **Main build** — everything routine, built in one pass.

Philosophy: "Every task boundary is an integration risk." Fewer boundaries = fewer bugs. Only genuinely hard things get isolated.

### 6. Visual QA closes the loop

Every piece of work is verified by capturing screenshots from the running game and analyzing them with vision models. Three modes:

- **Static** — reference image + one screenshot
- **Dynamic** — reference + frame sequence (for motion/physics)
- **Question** — free-form visual debugging without reference

Supports Gemini Flash (default), Claude vision (native), or both with aggregated verdicts. This catches bugs invisible to text analysis: z-fighting, floating objects, wrong scale, broken physics.

### 7. Domain quirks as institutional knowledge

`quirks.md` encodes dozens of Godot-specific traps that would otherwise cost hours of debugging per occurrence. Examples:

- `_ready()` doesn't fire during scene builder `_initialize()`
- `MultiMeshInstance3D` loses mesh reference after pack-and-save
- Camera lerp from origin causes visible swoop on first frame
- Frame-rate dependent drag needs `exp(-rate * delta)` not `(1 - drag)`

This is the highest-value, lowest-glamour pattern in the system.

### 8. Implementation loop without fixed iteration limit

The execution loop is: generate code -> build -> validate -> capture -> verify -> VQA -> fix -> repeat.

No hardcoded retry count. Judgment-based convergence:
- If there's progress, keep going
- If the same fix is attempted repeatedly without convergence, stop
- If the problem is architectural, replan instead of iterating

### 9. Scaffold produces compilable skeleton

The scaffold stage outputs real, compilable files — not pseudocode. project.godot, .csproj, script stubs with correct base classes and signal declarations, scene builder stubs. The project can be opened in Godot and validated before any real implementation begins.

### 10. Context hygiene via file persistence

Important state lives in files, not conversation. After each task: update PLAN.md status, write discoveries to MEMORY.md, git commit. If context gets polluted from debugging loops, manual compaction is used. The pipeline can resume from any point by reading the document set.

## What translates to Obsidian plugin development

| Godogen pattern | Obsidian equivalent | Notes |
|---|---|---|
| Meta-repo + publish.sh | Same pattern | Copy skills + CLAUDE.md into plugin folder |
| Progressive stage loading | Same pattern | Shorter pipeline (no assets/visual target) |
| Forked API lookup skill | Obsidian Plugin API reference | Smaller API, but same isolation benefit |
| Forked visual QA | Screenshot + vision analysis | Supplement to MCP bridge, not primary loop |
| Document protocol | PLAN.md, STRUCTURE.md, MEMORY.md | Same pattern, different schema |
| Risk-first decomposition | Same pattern | Different risk taxonomy (CodeMirror extensions, mobile compat, etc.) |
| Quirks file | obsidian-quirks.md | API traps, lifecycle gotchas, CSS instability |
| Scaffold -> build -> verify loop | scaffold -> build -> hot-reload -> bridge verify | MCP bridge makes verification richer |
| Scene builders | Not needed | Obsidian plugins are just TS/JS |
| Asset generation | Not needed | No visual asset pipeline |
| Visual target (reference.png) | Optional | Useful for UI-heavy plugins only |

## What's different

The biggest difference is the **verification bridge**. Godogen's feedback loop is one-directional: write code -> run engine -> capture frames -> analyze. The obsikit project has a two-way live bridge via MCP — the LLM can query Obsidian state, read errors, inspect the workspace, trigger commands, all in real time. This makes many checks that godogen needs vision QA for into simple programmatic queries:

- "Did the command register?" -> `obsidian_get_plugin_state`
- "Are there runtime errors?" -> `obsidian_get_errors`
- "Did the file get created?" -> `obsidian_read_file`

Vision QA becomes a supplement for UI appearance verification, not the primary feedback signal.

## Pipeline comparison

**Godogen:** user request -> visual target -> decompose -> scaffold -> assets -> execute (build -> capture -> VQA -> fix loop) -> presentation video

**Obsigen (proposed):** user request -> decompose -> scaffold -> execute (build -> hot-reload -> MCP verify + optional screenshot QA -> fix loop) -> demo vault
