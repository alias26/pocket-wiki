# pocket-wiki

A personal knowledge base that lives in Obsidian, grows with every source you add, and is queryable by Claude.

Inspired by [Andrej Karpathy's LLM Wiki concept](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

[한국어 README](README.ko.md)

## How it works

```
raw/              →   graphify --update   →   graphify-out/graph.json
(your sources)                                (knowledge graph)

                  →   /pocket-wiki        →   LLM Wiki/wiki/
                      (Claude Code)           (human-readable summaries)
```

1. You drop a source (URL, PDF, article) into `raw/`
2. [Graphify](https://github.com/safishamsi/graphify) extracts a knowledge graph — concepts, relationships, and "god nodes" (high-degree hubs) — from your sources
3. Claude navigates the graph to find relevant context efficiently, then writes wiki pages from your chosen perspective
4. Next time you ask a question, Claude reads the wiki first — draft pages are cross-checked against raw sources

## Prerequisites

- Python 3.9+
- [Obsidian](https://obsidian.md)
- [Claude Code](https://claude.ai/code)

**[Graphify](https://github.com/safishamsi/graphify)** (`pip install graphifyy`) — converts folders of docs, code, papers, and URLs into a queryable knowledge graph. Installed automatically by the setup script.

## Setup

**Mac/Linux**
```bash
bash setup.sh
```

**Windows**
```powershell
.\setup.ps1
```

The setup script:
1. Installs [Graphify](https://github.com/safishamsi/graphify) via pip (`pip install graphifyy`)
2. Registers the `/pocket-wiki` skill into Claude Code (`~/.claude/`)
3. Creates the folder structure

Then:
1. Open `LLM Wiki/` as your Obsidian vault
2. Install the **Local REST API** community plugin and enable it
3. Run `claude` from this directory

## Usage

### Add a source and build wiki
```
/pocket-wiki <url or title>
```
Claude fetches the source, updates the graph, discusses key points and perspective with you, then writes wiki pages.

### Query your knowledge
```
/pocket-wiki query <question>
```
Claude searches the wiki and answers. If wiki pages are missing, it reads raw sources and writes them on the fly.

### Health check
```
/pocket-wiki lint
```
Checks for: broken wikilinks, orphan pages, semantic overlaps (pages sharing 3+ tags), unlinked mentions.

### Decision history
```
/pocket-wiki decisions
/pocket-wiki decisions add <title>
```
View or record structural decisions (schema changes, merge/split choices, workflow updates) in ADR format.

## Concept page frontmatter

```yaml
---
title:
type: concept
domain:
tags: []
perspective: []   # optional: systems | practitioner | theory | history | interview | math
updated: YYYY-MM-DD
status: draft | stable | archived
---
```

`perspective` records the angle the page was written from — useful for filtering by focus area later (e.g. "show me all practitioner-perspective pages in the network domain").

## Folder structure

```
pocket-wiki/
├── raw/                 # your sources — local only, never committed
│   ├── files/           # manually added files
│   └── crawled/         # fetched by /pocket-wiki
├── LLM Wiki/
│   ├── wiki/
│   │   ├── sources/     # <slug>-source.md per source
│   │   └── <domain>/    # concept pages
│   └── _meta/
│       ├── schema.md    # frontmatter rules
│       ├── decisions.md # ADR — why things are the way they are
│       ├── index.md     # full wiki index (gitignored, local only)
│       └── log.md       # work log (gitignored, local only)
├── graphify-out/        # graph.json — gitignored, local only
├── CLAUDE.md            # workflow instructions for Claude
├── SKILL.md             # /pocket-wiki skill definition
├── setup.sh
└── setup.ps1
```

## Syncing your wiki

`raw/`, `graphify-out/`, `_meta/index.md`, and `_meta/log.md` are **gitignored by design** — they contain your personal source files and private browsing history.

To sync your wiki pages and graph across machines, push to a **private** repo:

```bash
# in your pocket-wiki directory
git add "LLM Wiki/wiki/" graphify-out/
git commit -m "sync wiki"
git push
```

`raw/` is intentionally local-only. If you need to back it up, use a separate sync tool (e.g. rsync, Syncthing, or a private cloud folder).

## License

[MIT](LICENSE)
