#!/bin/bash
# pocket-wiki setup (Mac/Linux)

echo "Setting up pocket-wiki..."

# 1. Install graphify
echo ""
echo "[1/4] Installing graphify..."
pip install graphifyy -q || pip3 install graphifyy -q
if [ $? -ne 0 ]; then echo "Failed to install graphify. Make sure pip is installed."; exit 1; fi

# 2. Register Claude Code skill
echo "[2/4] Registering Claude Code skill..."
python3 -m graphify install --platform claude

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
echo "  python3 -m graphify add <url> --dir raw/crawled"
echo ""
echo "Build wiki:"
echo "  Tell Claude: 'ingest [source name]'"
