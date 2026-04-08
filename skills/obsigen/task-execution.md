# Task Execution

Implement the planned MVP feature, then verify and fix until it works or a clear blocker is reached.

## Before writing code

1. Read `PLAN.md`, `STRUCTURE.md`, and `MEMORY.md`.
2. Call `obsidian_get_capabilities`.
3. Use the reported capabilities to choose the verification path.
4. Read `obsidian-quirks.md` before changing plugin lifecycle, views, or vault writes.

## Implementation loop

Use this loop:

1. Implement the smallest missing piece.
2. Build the plugin.
3. Reload the plugin or app using the best available tooling.
4. Verify command, view, and behavior.
5. Record results in `MEMORY.md`.
6. Update task status in `PLAN.md`.
7. Fix issues and repeat.

## Verification order

Prefer this order:

1. `obsidian_get_capabilities`
2. plugin reload
3. error check
4. command registration and execution
5. view open or reveal
6. one concrete behavior check

Use CLI-backed tools where available for:

- reload
- command execution
- errors
- DOM/CSS inspection
- screenshot capture
- eval

Use bridge-backed tools where available for:

- plugin state
- active file/view
- current vault/file helpers

## MVP success conditions

The run is successful when all of these are true:

- plugin loads without uncaught runtime errors
- command is present and executable
- sidebar or custom view opens
- the requested vault interaction works once end-to-end

## Visual verification

After command/view verification passes, confirm the UI renders correctly:

1. Take a screenshot: `obsidian_take_screenshot`
2. Read the screenshot to check for blank views, error states, or broken layout
3. Use DOM queries to verify specifics:
   - `obsidian_query_dom` — check element presence, text content, structure
   - `obsidian_get_css` — check computed styles (dimensions, visibility, overflow)

Checklist:

- view container is not empty
- expected heading/text content is present
- no visible error messages or stack traces
- no layout overflow or zero-dimension elements
- interactive elements (buttons, inputs) are present if expected

If the screenshot shows a problem that DOM queries can't explain, record it in `MEMORY.md` with the screenshot path and move on — don't loop on visual issues that need human judgement.

## Failure handling

If verification fails:

- fix the smallest concrete cause first
- do not branch into unrelated refactors
- after repeated failures, write the blocker clearly into `MEMORY.md` and narrow the plan if needed

## Documentation updates during execution

Keep `PLAN.md` and `MEMORY.md` current.

Minimum updates:

- task status changed
- important error encountered
- verification result
- workaround or discovery that affects the next step
