# Decomposer

Turn the user's plugin request into a minimal end-to-end MVP plan.

## Goal

Write `PLAN.md` that is small enough to execute reliably and precise enough to verify automatically.

If `PLAN.md` does not exist yet, start from `${CLAUDE_SKILL_DIR}/templates/PLAN.md`.
Replace every `<...>` placeholder before moving on.

## Default decomposition rule

Reduce the request to the narrowest useful plugin slice:

- one command
- one sidebar or custom view
- one small vault interaction

If the user asked for more, keep the MVP slice in scope and record the rest as deferred work.

## Plugin identity

Choose the plugin identity during decomposition so scaffold does not have to guess.

- Display name: short, Title Case, grounded in the request
- Plugin id: lowercase kebab-case derived from the display name
- Remove generic tokens like `obsidian` and `plugin` from the id
- The id must be stable once written into `PLAN.md`

## Platform classification

Choose one:

- `cross-platform safe`
- `desktop-only`

Mark `desktop-only` only if the feature actually depends on desktop-specific behavior.

## Risks

Only isolate real risk items. Typical Obsidian plugin risks:

- custom view lifecycle
- deferred view handling
- command registration and reload behavior
- vault write behavior
- mobile or desktop-only assumptions
- expensive startup work

Do not create a long task graph for routine UI and file work.

## Verification criteria

Every plan should contain explicit checks for:

- plugin loads without runtime errors
- command is registered and executable
- sidebar or custom view can be opened
- one observable vault behavior works as intended

## Scope pressure rule

If the request is too broad for the current MVP skill:

- keep a single working slice in `MVP slice`
- put the rest in `Deferred scope`
- do not pretend the first run will ship the full vision

## Task list rule

Start from the canonical task list in the `PLAN.md` template.

- Keep the scaffold/build/verify spine intact
- Add only request-specific tasks that materially change implementation
- Mark `Current stage` as `decompose` when first writing the file
