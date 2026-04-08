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

After command/view verification passes, confirm the UI renders correctly using DOM and CSS inspection. Screenshots are supplementary artifacts for human review — do not rely on reading screenshots for automated checks.

Automated checks (use these):

- `obsidian_query_dom` — verify element presence, text content, structure
- `obsidian_get_css` — verify computed styles (dimensions, visibility, overflow)

Checklist:

- view container is not empty (query for expected child elements)
- expected heading/text content is present (query text content)
- no visible error elements (query for `.notice` or error-class elements)
- no zero-dimension elements (check computed width/height via CSS)
- interactive elements (buttons, inputs) are present if expected

Screenshot (supplementary):

- `obsidian_take_screenshot` — capture for human review or `MEMORY.md` reference
- Do not attempt pixel-level analysis — that is not an available capability
- If DOM/CSS checks pass but something still seems wrong, save the screenshot path in `MEMORY.md` and note it for human review

## Failure handling

If verification fails:

- fix the smallest concrete cause first
- do not branch into unrelated refactors
- after repeated failures, write the blocker clearly into `MEMORY.md` and narrow the plan if needed

## Documentation updates during execution

Keep `PLAN.md` and `MEMORY.md` current.

Minimum updates:

- task status changed in `PLAN.md`
- `Current stage`, `Current focus`, or `Blockers` changed in `PLAN.md`
- important error encountered
- verification result
- workaround or discovery that affects the next step
- file/path decisions or runtime findings added to `MEMORY.md`
