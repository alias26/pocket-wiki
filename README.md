# pocket-wiki

A personal knowledge base that lives in Obsidian, grows with every source you add, and is accessible from anywhere via git.

Inspired by [Andrej Karpathy's LLM Wiki concept](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## How it works

```
raw/          →   graphify   →   LLM Wiki/graph/    (Obsidian graph nodes)
(your sources)    --update       LLM Wiki/wiki/     (Claude-written summaries)
```

- **raw/**: Drop papers, articles, notes here. Never committed — stays local.
- **graph/**: Auto-generated knowledge graph nodes by Graphify. Visualized in Obsidian.
- **wiki/**: Curated summaries written by Claude. The knowledge that persists across sessions.

## Prerequisites

- Python + pip
- [Obsidian](https://obsidian.md)
- [Claude Code](https://claude.ai/code)

## Setup

**Mac/Linux**
```bash
bash setup.sh
```

**Windows**
```powershell
.\setup.ps1
```

Then:
1. Open `LLM Wiki/` as your Obsidian vault
2. Install the **Local REST API** community plugin and enable it
3. Run `claude` from this directory

## Usage

### Add a source
```bash
python -m graphify add <url> --dir raw/crawled
```

### Update the knowledge graph
```bash
python -m graphify --update
```

### Build wiki pages
Tell Claude:
```
"<source name> ingest해줘"
```
Claude reads the graph and writes structured wiki pages into `LLM Wiki/wiki/`.

### Query your knowledge
Just ask Claude:
```
"Transformer 아키텍처 설명해줘"
```

## Folder structure

```
pocket-wiki/
├── raw/
│   ├── files/       # manually added files
│   └── crawled/     # graphify add output
├── LLM Wiki/
│   ├── wiki/        # Claude-written pages (gitignored — yours only)
│   ├── graph/       # Graphify nodes (gitignored — auto-generated)
│   └── _meta/       # schema, index, log
├── graphify-out/    # graph.json (gitignored)
├── CLAUDE.md        # workflow instructions for Claude
├── setup.sh
└── setup.ps1
```

## Sync your wiki anywhere

Push `LLM Wiki/wiki/` and `graphify-out/graph.json` to your own **private** repo to access your knowledge from any machine. The public pocket-wiki repo only contains the template structure.
