---
name: pocket-wiki
description: "personal knowledge base — ingest sources, query wiki, lint health check"
trigger: /pocket-wiki
---

# /pocket-wiki

Manage a personal knowledge base built on Graphify + LLM Wiki pattern.

## Usage

```
/pocket-wiki <url or title>       # ingest a new source
/pocket-wiki query <question>     # query the wiki
/pocket-wiki lint                 # health check
```

## What You Must Do When Invoked

### Step 0 — Find repo root

Before anything else, read `pocketRoot` from the config file saved during setup:

```bash
CONFIG="$HOME/.claude/skills/pocket-wiki/config.json"
if [ ! -f "$CONFIG" ]; then
    echo "ERROR: pocket-wiki not set up. Run setup.ps1 or setup.sh first."
    exit 1
fi
POCKET_ROOT=$(python3 -c "import json; print(json.load(open('$CONFIG'))['pocketRoot'])")
echo "pocketRoot: $POCKET_ROOT"
cd "$POCKET_ROOT"
```

All subsequent bash commands must run from `$POCKET_ROOT`.

Parse the argument after `/pocket-wiki`:
- If it starts with `query` → run QUERY flow
- If it starts with `lint` → run LINT flow
- Otherwise → run INGEST flow (treat the argument as a URL or search term)

---

## INGEST flow

Run these steps in order. Do not skip steps.

### Step 1 — Collect source

If a URL was given: run immediately without asking.
```bash
cd "$REPO_ROOT" && python -m graphify add <url> --dir raw/crawled
```

If only a title or keyword was given: search the web for the most relevant URL (paper, article, official page), show the user what you found and ask for confirmation. After confirmation, run the command above.

If it fails, tell the user what went wrong and stop.

### Step 2 — Update graph

```bash
cd "$REPO_ROOT" && python -m graphify --update
```

### Step 3 — Discuss with user

Do NOT write wiki pages yet.

Read the raw source file from `raw/crawled/` or `raw/files/`. Share the key claims and interesting points with the user. Ask what angle or perspective to emphasize. Wait for the user's response before proceeding.

### Step 4 — Write source page

Create `LLM Wiki/wiki/sources/<slug>.md`:
- Frontmatter: type=source, author, added (today), domain, source_url, source_file (path to raw file), status=summarized
- Body: 핵심 주장, 유저 관점 반영한 내 메모, ## 관련 section with [[wikilinks]]
- `[[wikilinks]]` go in body only, never in frontmatter

### Step 5 — Update concept/entity pages

For each key concept or entity in the source:
- If `LLM Wiki/wiki/<domain>/<concept>.md` exists → update it (note contradictions explicitly)
- If it doesn't exist → create it with frontmatter: type=concept, domain, tags, updated (today), status=draft

A single source can touch 10-15 pages.

### Step 6 — Update _meta/

Update `LLM Wiki/_meta/index.md`: add new pages with link + one-line summary.

Append to `LLM Wiki/_meta/log.md`:
```
## [YYYY-MM-DD] ingest | <source title>
생성/수정한 페이지: page1, page2, ...
```

---

## QUERY flow

### Step 1 — Traverse graph

```bash
cd "$POCKET_ROOT" && python -m graphify query "<question>" --budget 2000
```

Find relevant nodes. This is the navigator — it tells you what to read next.

### Step 2 — Read wiki pages if they exist

For each relevant node found, check if a corresponding wiki page exists in `LLM Wiki/wiki/`.
- Wiki page exists → read it (synthesized knowledge, fast)
- Wiki page doesn't exist → read the raw source file it came from

### Step 3 — Answer + ingest if needed

Synthesize and answer.

If wiki pages were missing and you read raw files instead:
- Write wiki pages now (same as INGEST steps 4-6)
- Next time the same topic comes up, wiki will be ready

If the answer itself contains a comparison, analysis, or newly discovered connection — save it as a new wiki page too. Good answers compound knowledge.

Append to `LLM Wiki/_meta/log.md`:
```
## [YYYY-MM-DD] query | <question summary>
답변 저장 위치: wiki/domain/page.md
```

---

## LINT flow

Check wiki health in order:

1. Compare `LLM Wiki/_meta/index.md` against actual files — find missing or mismatched entries
2. Find `[[wikilinks]]` in body text that have no corresponding page (outbound orphans)
3. Find pages that no other page links to (inbound orphans)
4. Find pages with `status: draft` that haven't been updated in a long time
5. Find contradictions between concept pages
6. Identify data gaps — suggest new questions to investigate and new sources to add

Append to `LLM Wiki/_meta/log.md`:
```
## [YYYY-MM-DD] lint
발견한 문제: ...
제안된 다음 소스: ...
```

---

## Rules

- Never modify files in `raw/`, `graphify-out/`, or `LLM Wiki/graph/`
- Never write wiki pages without discussing with the user first (INGEST step 3)
- `[[wikilinks]]` in body `## 관련` section only — never in frontmatter
- If graph.json doesn't exist, tell the user to run `/pocket-wiki <source>` first
