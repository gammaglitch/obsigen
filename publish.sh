#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_TEMPLATE="$REPO_ROOT/CLAUDE.md"
SKILLS_SOURCE="$REPO_ROOT/skills"
OBSIKIT_SOURCE="$REPO_ROOT/templates/obsikit"

usage() {
	cat <<'EOF'
Usage: ./publish.sh [--force] <target_dir>

Publishes the current obsigen workspace into a target plugin project folder.

What gets published:
- .claude/skills/ from this repo, if present
- CLAUDE.md from this repo
- .obsigen/templates/obsikit/ as the pinned scaffold source

Options:
  --force    Delete existing target contents before publishing
EOF
}

FORCE=0
if [ "${1:-}" = "--force" ]; then
	FORCE=1
	shift
fi

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

TARGET="$(cd "$1" 2>/dev/null && pwd || (mkdir -p "$1" && cd "$1" && pwd))"

if [ "$FORCE" -eq 1 ] && [ -d "$TARGET" ]; then
	echo "Force: cleaning $TARGET"
	rm -rf "${TARGET:?}/"*
	rm -rf "${TARGET:?}/".[!.]*
	rm -rf "${TARGET:?}/"..?*
fi

mkdir -p "$TARGET"

if [ ! -f "$CLAUDE_TEMPLATE" ]; then
	echo "Missing template: $CLAUDE_TEMPLATE" >&2
	exit 1
fi

if [ ! -d "$OBSIKIT_SOURCE" ]; then
	echo "Missing obsikit scaffold source: $OBSIKIT_SOURCE" >&2
	exit 1
fi

echo "Publishing to: $TARGET"

mkdir -p "$TARGET/.claude/skills"
if [ -d "$SKILLS_SOURCE" ]; then
	rsync -a --delete \
		--exclude='__pycache__/' \
		"$SKILLS_SOURCE/" "$TARGET/.claude/skills/"
	echo "Copied skills"
else
	echo "Warning: no skills directory found at $SKILLS_SOURCE"
fi

cp "$CLAUDE_TEMPLATE" "$TARGET/CLAUDE.md"
echo "Copied CLAUDE.md"

mkdir -p "$TARGET/.obsigen/templates/obsikit"
rsync -a --delete \
	--exclude='.git/' \
	--exclude='node_modules/' \
	--exclude='dist/' \
	--exclude='.DS_Store' \
	"$OBSIKIT_SOURCE/" "$TARGET/.obsigen/templates/obsikit/"
echo "Copied obsikit scaffold template"

if [ ! -f "$TARGET/.gitignore" ]; then
	cat > "$TARGET/.gitignore" <<'EOF'
.claude
.obsigen
node_modules
dist
EOF
	echo "Created .gitignore"
fi

git -C "$TARGET" init -q 2>/dev/null || true

echo "Done."
