# Obsigen MVP Requirements Checklist

Goal: prove that `obsigen` can publish a reusable skill pack, generate a working Obsidian plugin from a plain-language request, and verify the result against a live Obsidian instance built on `obsikit`.

## MVP outcome

- [ ] A user can run a publish command from this repo to prepare a fresh plugin workspace.
- [ ] The published workspace contains the skills and instructions needed to run the pipeline from inside Claude Code.
- [ ] The pipeline can take one simple plugin request and turn it into a working plugin scaffold based on `obsikit`.
- [ ] The generated plugin can be built and loaded in the existing Obsidian test harness.
- [ ] The pipeline can verify success using the existing bridge and e2e/runtime feedback, without manual inspection as the primary path.

## 1. Delivery and workspace bootstrap

- [x] Add `publish.sh` at repo root.
- [x] `publish.sh` copies `skills/` into the target workspace.
- [x] `publish.sh` writes a `CLAUDE.md` template into the target workspace.
- [x] `publish.sh` copies the vendored `obsikit` scaffold template into the target workspace so scaffold can run without depending on the source repo.
- [x] `publish.sh` initializes the target workspace if it does not exist yet.
- [x] `publish.sh` is safe to rerun and has a clear overwrite strategy.
- [ ] Document the expected user flow in the repo README or publish usage output.
- [x] Treat `obsikit` as a pinned scaffold source inside this repo, not as a git submodule.

## 2. Minimal skill set

- [x] Create `skills/obsigen/SKILL.md` as the main orchestrator entry point.
- [x] Add `decomposer.md` for converting a plugin request into scope, risks, and verification criteria.
- [x] Add `scaffold.md` for creating the initial plugin structure from `obsikit`.
- [x] Add `task-execution.md` for the implementation and fix loop.
- [x] Add `obsidian-quirks.md` for high-value platform and API traps.
- [x] Keep stage loading progressive so the orchestrator does not load all instructions at once.

## 3. Persistent pipeline documents

- [x] Define `PLAN.md` as the source of truth for scope, task status, and verification criteria.
- [x] Define `STRUCTURE.md` for plugin architecture and key files.
- [x] Define `MEMORY.md` for discoveries, failures, and workarounds.
- [ ] The pipeline can resume from these files instead of depending on chat history alone.

## 4. Scaffold requirements

- [ ] The scaffold step starts from `obsikit` rather than inventing a plugin structure from scratch.
- [x] `obsikit` is stored as a vendored snapshot or template source, not as a nested git repo in the working tree.
- [x] The repo records the upstream `obsikit` source and pinned revision used for the scaffold base.
- [ ] The scaffold removes or replaces the example feature with plugin-specific code seams.
- [ ] The scaffold produces a compilable plugin skeleton, not pseudocode.
- [ ] The scaffold names the plugin consistently across manifest, package metadata, and source files where required.
- [ ] The scaffold leaves a clear place for feature code, vault helpers, and UI components.

## 5. Execution loop requirements

- [ ] The orchestrator can implement a simple feature request after scaffolding.
- [ ] The first supported request shape is intentionally narrow:
  a plugin with one command, one sidebar view, and one small unit of vault interaction.
- [ ] The loop includes build, load or reload, runtime verification, and fixup.
- [ ] The loop updates `PLAN.md` and `MEMORY.md` as work progresses.
- [ ] The loop stops on success or on a clear blocked state instead of spinning indefinitely.

## 6. Verification requirements

- [ ] Use the existing `obsikit` runtime and bridge as the primary verification path.
- [ ] Verify that the plugin loads in Obsidian without uncaught runtime errors.
- [ ] Verify that the sidebar view can be opened.
- [ ] Verify that the generated command is registered and callable.
- [ ] Verify at least one observable plugin behavior through the bridge or test harness.
- [ ] Capture enough failure information to support automated fixes.

## 7. MVP demo scenario

- [ ] Define one canonical demo prompt for the MVP.
- [ ] The demo prompt should be simple but representative, for example:
  create a plugin with a sidebar that lists markdown files and a command that appends a line to the active note.
- [ ] Run the full flow against that prompt from publish -> scaffold -> implement -> verify.
- [ ] Record the exact commands and expected success signals for repeating the demo.

## 8. Explicit non-goals for MVP

- [ ] No screenshot-to-vision QA loop yet.
- [ ] No separate Obsidian API lookup skill yet.
- [ ] No broad bridge expansion beyond what is required to prove the first workflow.
- [ ] No advanced plugin categories yet such as CodeMirror extensions, settings tabs, mobile-specific UX, or multi-view plugins.
- [ ] No marketplace packaging or release automation yet.
- [ ] No submodule-based dependency flow for `obsikit`.

## Exit criteria

- [ ] A fresh target folder can be prepared from this repo in one command.
- [ ] Claude Code in that target folder can follow the published instructions to create one simple plugin from a natural-language request.
- [ ] The plugin builds and loads in the existing Obsidian harness.
- [ ] Verification confirms the view, command, and one vault behavior work.
- [ ] The resulting workspace is resumable because `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md` were written.

## Current status notes

- `publish.sh` and the root `CLAUDE.md` template now exist.
- The publish flow now copies a tracked vendored template from `templates/obsikit/` into `.obsigen/templates/obsikit/`.
- The local `obsikit/` clone is now treated as external development context rather than part of the main repo.
- `skills/obsigen/` now exists with the first orchestrator skeleton and supporting files.
- Canonical templates for `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md` now exist under `skills/obsigen/templates/`.
- The next blocking implementation step is proving one canonical publish -> scaffold -> implement -> verify run end to end.
