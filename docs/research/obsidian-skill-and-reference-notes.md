# Obsidian Skill And Reference Notes

Research snapshot for `obsigen` as of 2026-04-08.

This note covers two things:

- what the cloned `obsidian-skills` repo contributes
- what the official skill-authoring guidance suggests for building `obsigen`

## What the cloned `obsidian-skills` repo is

The local `obsidian-skills/` clone is not a plugin-generation framework. It is a general skill pack for working with Obsidian content and tooling.

Current skills in that repo:

- `obsidian-markdown`
- `obsidian-bases`
- `json-canvas`
- `obsidian-cli`
- `defuddle`

Most of these are oriented around vault content authoring, not community plugin scaffolding.

## The one skill most relevant to obsigen

`obsidian-cli` is the most directly useful inspiration for `obsigen` because it encodes a plugin-development loop around the official Obsidian CLI:

1. reload plugin
2. inspect errors
3. verify visually or via DOM inspection
4. inspect console output

That matches the exact type of loop `obsigen` needs, even if the current MVP still uses the `obsikit` bridge.

## What to borrow from the cloned skills

Useful patterns to copy:

- concise descriptions that clearly state what the skill does and when to use it
- narrow scope per skill
- command-oriented instructions instead of broad theory
- explicit developer workflows

What not to copy blindly:

- vault-authoring assumptions that are unrelated to plugin generation
- CLI-specific instructions as if they are universally available in our Docker harness

## Official skill-authoring guidance that matters

The official skill docs emphasize:

- concise `SKILL.md` files
- strong descriptions for discovery
- progressive disclosure instead of one giant instruction file
- keeping references one level deep from `SKILL.md`
- using scripts for deterministic operations
- testing skills with real usage

This matches the direction already identified from studying `godogen`.

## Implications for obsigen skill design

The first `obsigen` skill set should likely follow this structure:

- `skills/obsigen/SKILL.md`
- `decomposer.md`
- `scaffold.md`
- `task-execution.md`
- `obsidian-quirks.md`
- optional later references for release and verifier modes

And it should avoid:

- deeply nested documentation chains
- stuffing full API references into the main skill
- mixing scaffold instructions with every possible Obsidian feature

## Suggested local reference strategy

Rather than copying entire upstream docs into the repo, keep a curated reference pack:

- these research summaries in `docs/research/`
- vendored scaffold source in the template path
- later, a pinned copy or scripted fetch of selected official sources if the skill needs offline reference material

If we later decide to bring in more upstream material, the highest-value additions would be:

- pinned `obsidian-api` typings
- pinned sample plugin snapshot
- selected official docs pages that cover release policy and view/runtime gotchas

## Sources

- Local clone: `obsidian-skills/README.md`
- Local clone: `obsidian-skills/skills/obsidian-cli/SKILL.md`
- Claude Docs: Agent Skills overview
  https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview
- Claude API Docs: Skill authoring best practices
  https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
