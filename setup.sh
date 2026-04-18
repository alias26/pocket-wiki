#!/bin/bash
# pocket-wiki setup (Mac/Linux)

echo "Setting up pocket-wiki..."

# 1. Install graphify
echo ""
echo "[1/4] Installing graphify..."
pip install graphifyy -q || pip3 install graphifyy -q
if [ $? -ne 0 ]; then echo "Failed to install graphify. Make sure pip is installed."; exit 1; fi

# 2. Register Claude Code skills
echo "[2/4] Registering Claude Code skills..."
python3 -m graphify install --platform claude

SKILL_DIR="$HOME/.claude/skills/pocket-wiki"
mkdir -p "$SKILL_DIR"
cp SKILL.md "$SKILL_DIR/SKILL.md"

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if ! grep -q "pocket-wiki" "$CLAUDE_MD" 2>/dev/null; then
    echo "" >> "$CLAUDE_MD"
    echo "# pocket-wiki" >> "$CLAUDE_MD"
    echo "- **pocket-wiki** (\`~/.claude/skills/pocket-wiki/SKILL.md\`) - personal knowledge base. Trigger: \`/pocket-wiki\`" >> "$CLAUDE_MD"
    echo "pocket-wiki skill registered."
else
    echo "pocket-wiki skill already registered."
fi

# 3. Create folder structure
echo "[3/4] Creating folder structure..."
mkdir -p raw/files raw/crawled graphify-out
mkdir -p "LLM Wiki/graph"
mkdir -p "LLM Wiki/wiki/sources"
mkdir -p "LLM Wiki/_meta"
echo "Folders created."

# 4. Done
echo ""
echo "[4/4] Done!"
echo ""
echo "Next steps:"
echo "  1. Open 'LLM Wiki/' as your Obsidian vault"
echo "  2. Install 'Local REST API' community plugin and enable it"
echo "  3. Run Claude Code from this directory:"
echo "       cd $(pwd)"
echo "       claude"
echo ""
echo "Add a source:"
echo "  /pocket-wiki <url or title>"
echo ""
echo "Query your wiki:"
echo "  /pocket-wiki query <question>"
