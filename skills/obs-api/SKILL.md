---
name: obs-api
description: |
  Look up Obsidian plugin API — classes, methods, events, interfaces.
  Use when you need to find which class to use or look up specific API details.
context: fork
model: sonnet
agent: Explore
---

# Obsidian API Lookup

$ARGUMENTS

## How to answer

1. Read `${CLAUDE_SKILL_DIR}/doc_api/_common.md` — index of ~30 core plugin-dev classes
2. If the class isn't there, read `${CLAUDE_SKILL_DIR}/doc_api/_other.md`
3. Read `${CLAUDE_SKILL_DIR}/doc_api/{ClassName}.md` — full API with methods, properties, and descriptions
4. Return what the caller needs:
   - **Specific question** (e.g. "how to register a command") — return relevant methods/properties with descriptions
   - **Full API request** (e.g. "full API for Vault") — return the entire class doc

**Standalone functions:** `${CLAUDE_SKILL_DIR}/doc_api/_functions.md` — module-level exports like `addIcon`, `normalizePath`, `parseYaml`, etc. Read when the caller asks about a utility that isn't a class method.

**Patterns reference:** `${CLAUDE_SKILL_DIR}/patterns.md` — common plugin patterns and Obsidian-specific TypeScript idioms. Read when the caller asks about how to use an API, not just what it is.

Docs are vendored in `doc_api/`. Version info is in `${CLAUDE_SKILL_DIR}/VERSION`.
