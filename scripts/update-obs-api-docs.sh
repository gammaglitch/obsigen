#!/usr/bin/env bash
# Refresh the vendored obs-api docs from obsidocs.
# Run manually when you want newer Obsidian API docs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOC_API="$REPO_ROOT/skills/obs-api/doc_api"
VERSION_FILE="$REPO_ROOT/skills/obs-api/VERSION"
TMPDIR=$(mktemp -d)

trap 'rm -rf "$TMPDIR"' EXIT

OBSIDOCS_REPO="https://github.com/gammaglitch/obsidocs.git"

# Optional: pass a tag as argument (e.g., ./update-obs-api-docs.sh v1.8.0)
TAG="${1:-}"

if [ -n "$TAG" ]; then
    echo "Fetching obsidocs at tag $TAG..."
    git clone --depth 1 --branch "$TAG" "$OBSIDOCS_REPO" "$TMPDIR/obsidocs"
else
    echo "Fetching latest obsidocs..."
    git clone --depth 1 "$OBSIDOCS_REPO" "$TMPDIR/obsidocs"
    TAG=$(git -C "$TMPDIR/obsidocs" describe --tags --exact-match 2>/dev/null || echo "untagged")
fi

if [ ! -d "$TMPDIR/obsidocs/docs" ]; then
    echo "Error: no docs/ directory in obsidocs" >&2
    exit 1
fi

COMMIT=$(git -C "$TMPDIR/obsidocs" rev-parse --short HEAD)

# Replace doc_api contents
rm -rf "$DOC_API"
cp -r "$TMPDIR/obsidocs/docs" "$DOC_API"

COUNT=$(ls "$DOC_API"/*.md | wc -l)

# Update VERSION
cat > "$VERSION_FILE" << EOF
upstream_repo: https://github.com/obsidianmd/obsidian-api
upstream_version: ${TAG#v}
source_repo: $OBSIDOCS_REPO
source_commit: $COMMIT
source_tag: $TAG
refreshed: $(date -u +%Y-%m-%d)
EOF

echo "Updated doc_api: $COUNT files from obsidocs $TAG ($COMMIT)"
