#!/bin/bash
# Install Ralph into ./ralph/ in the current directory
# Usage: curl -fsSL https://raw.githubusercontent.com/richardwu/agent-skills/main/ralph/install.sh | sh

set -e

REPO="richardwu/agent-skills"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/ralph"
DEST="./script/ralph"

FILES="ralph.sh prompt.md CLAUDE.md"

mkdir -p "$DEST"

for file in $FILES; do
  echo "Downloading $file..."
  curl -fsSL "$BASE_URL/$file" -o "$DEST/$file"
done

chmod +x "$DEST/ralph.sh"

echo "Ralph installed to $DEST/"
echo "Next steps:"
echo "  1. Create a prd.json in $DEST/ (or use the 'ralph' skill to convert a PRD)"
echo "  2. Run: $DEST/ralph.sh [--tool amp|claude] [max_iterations]"
