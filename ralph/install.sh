#!/bin/bash
# Install Ralph into ./scripts/ralph/ in the current directory
# Usage: curl -fsSL https://raw.githubusercontent.com/richardwu/agent-skills/main/ralph/install.sh | sh

set -e

REPO="richardwu/agent-skills"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/ralph"
DEST="./scripts/ralph"

FILES="ralph.sh prompt.md CLAUDE.md"

# Check if files already exist
if [ -d "$DEST" ] && [ -f "$DEST/ralph.sh" ]; then
  echo "Ralph scripts already exist at $DEST/"
  read -p "Do you want to overwrite? [Y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]] && [ ! -z "$REPLY" ]; then
    echo "Aborted. Existing installation preserved."
    exit 0
  fi
fi

mkdir -p "$DEST"

for file in $FILES; do
  echo "Downloading $file..."
  curl -fsSL "$BASE_URL/$file" -o "$DEST/$file"
done

chmod +x "$DEST/ralph.sh"

echo "Ralph installed to $DEST/"
echo ""
echo "Installing skills..."
npx skills add https://github.com/richardwu/agent-skills --skill ralph prd

echo ""
echo "Next steps:"
echo "  1. Create a PRD based on a prompt with \`/prd\`"
echo "  2. Run \`/ralph\` once your PRD is created in step (1)"
