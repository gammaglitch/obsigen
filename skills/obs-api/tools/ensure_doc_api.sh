#!/usr/bin/env bash
# Bootstrap doc_api for obs-api skill.
# Tries to match the plugin's minAppVersion to an obsidocs tag.
# Falls back to latest if no matching tag exists.
# Safe to re-run — skips if doc_api/ already exists.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOC_API="$SKILL_DIR/doc_api"

if [ -d "$DOC_API" ] && [ -f "$DOC_API/_common.md" ]; then
    exit 0
fi

echo "Bootstrapping doc_api..."

# Try to find minAppVersion from the plugin's manifest.json
TARGET_VERSION=""
MANIFEST=""
for candidate in "./manifest.json" "../manifest.json" "../../manifest.json"; do
    if [ -f "$candidate" ]; then
        MANIFEST="$candidate"
        break
    fi
done

if [ -n "$MANIFEST" ]; then
    TARGET_VERSION=$(node -p "try{require('./$MANIFEST').minAppVersion}catch{''}" 2>/dev/null || true)
fi

OBSIDOCS_DIR="$SKILL_DIR/doc_source/obsidocs"
REPO_URL="https://github.com/gammaglitch/obsidocs.git"

if [ -n "$TARGET_VERSION" ]; then
    TAG="v${TARGET_VERSION}"
    echo "Plugin targets Obsidian $TARGET_VERSION, looking for tag $TAG..."

    # Try cloning at the matching tag
    if git clone --depth 1 --branch "$TAG" "$REPO_URL" "$OBSIDOCS_DIR" 2>/dev/null; then
        echo "Matched obsidocs $TAG"
    else
        echo "Tag $TAG not found, falling back to latest"
        rm -rf "$OBSIDOCS_DIR"
        git clone --depth 1 "$REPO_URL" "$OBSIDOCS_DIR"
    fi
else
    echo "No manifest found, using latest"
    git clone --depth 1 "$REPO_URL" "$OBSIDOCS_DIR"
fi

cp -r "$OBSIDOCS_DIR/docs" "$DOC_API"

echo "doc_api ready at $DOC_API"
