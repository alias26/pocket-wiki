# pocket-wiki

A personal knowledge base that lives in Obsidian, grows with every source you add, and is accessible from anywhere via git.

Inspired by [Andrej Karpathy's LLM Wiki concept](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## How it works

```
raw/              →   graphify --update   →   graphify-out/graph.json
(your sources)                                (knowledge graph for Claude)
                  →   /pocket-wiki        →   LLM Wiki/wiki/
                      (Claude)                (human-readable summaries)
```

- **raw/**: Your source files. Never committed — stays local.
- **graphify-out/graph.json**: Knowledge graph Claude uses to navigate sources efficiently.
- **wiki/**: Curated pages written by Claude. The knowledge that persists across sessions.
  - `wiki/sources/<slug>-source.md` — one page per source
  - `wiki/<domain>/<concept>.md` — concept/entity pages

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

### Add a source and build wiki
```
/pocket-wiki <url or title>
```
Claude fetches the source, updates the graph, discusses key points with you, and writes wiki pages.

### Query your knowledge
```
/pocket-wiki query <question>
```
Claude searches the wiki and answers. If wiki pages are missing, it reads raw sources and writes them on the fly.

### Health check
```
/pocket-wiki lint
```
Checks for broken wikilinks, orphan pages, semantic overlaps (pages sharing 3+ tags), and unlinked mentions (page titles appearing as plain text without `[[...]]`).

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

`perspective` records the angle the page was written from — useful for filtering by focus area later.

## Folder structure

```
pocket-wiki/
├── raw/
│   ├── files/       # manually added files
│   └── crawled/     # fetched by /pocket-wiki
├── LLM Wiki/
│   ├── wiki/
│   │   ├── sources/     # <slug>-source.md per source
│   │   └── <domain>/    # concept pages
│   └── _meta/
│       ├── schema.md    # frontmatter rules
│       ├── decisions.md # ADR — why things are the way they are
│       ├── index.md     # full wiki index (gitignored)
│       └── log.md       # work log (gitignored)
├── graphify-out/    # graph.json (gitignored)
├── CLAUDE.md        # workflow instructions for Claude
├── SKILL.md         # /pocket-wiki skill definition
├── setup.sh
└── setup.ps1
```

## Sync your wiki anywhere

Push `LLM Wiki/wiki/` and `graphify-out/graph.json` to your own **private** repo to access your knowledge from any machine. The public pocket-wiki repo only contains the template structure.
