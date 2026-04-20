---
name: pocket-wiki
description: "personal knowledge base — ingest sources, query wiki, lint health check"
trigger: /pocket-wiki
---

# /pocket-wiki

Manage a personal knowledge base built on Graphify + LLM Wiki pattern.

## Usage

```
/pocket-wiki <url or title>           # quick ingest — no discussion, defaults applied
/pocket-wiki discuss <url or title>   # ingest with perspective discussion
/pocket-wiki query <question>         # query the wiki
/pocket-wiki lint                     # health check
/pocket-wiki review                   # list pages needing review
/pocket-wiki review <slug or domain>  # review a specific page or domain
/pocket-wiki decisions                # show decision history
/pocket-wiki decisions add <title>    # record a new structural decision
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
- If it starts with `decisions` → run DECISIONS flow
- If it starts with `review` → run REVIEW flow
- If it starts with `discuss` → run INGEST flow in **discuss mode** (treat the rest as a URL or search term)
- Otherwise → run INGEST flow in **quick mode** (default — treat the argument as a URL or search term)

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

### Step 3 — Discussion (mode-dependent)

**Quick mode (default)** — fully autonomous, no user input:
- **Auto-infer `perspective`** from source type and content. Never leave empty. Inference rules:
  - Paper / arxiv / academic source → `theory` (add `math` if heavy formal content)
  - Blog post / tutorial / how-to / docs with code → `practitioner`
  - System internals / architecture / OS / hardware docs → `systems`
  - Tech evolution / version history / changelog / comparison → `history`
  - Interview prep / Q&A format → `interview`
  - Combine multiple when content spans angles (e.g. applied ML paper → `[theory, practitioner]`)
- If similar pages found (3+ shared tags or near-identical title), **auto-update** existing pages rather than asking. Mention what was auto-updated in the final summary.
- Do not block on user input. Proceed straight to Step 4.

**Discuss mode** (when invoked with `discuss` keyword) — current full conversation:
- Read the raw source file from `raw/crawled/` or `raw/files/`. Share key claims and interesting points with the user.
- Before asking about perspective, scan existing wiki pages in the same domain:
  - Pages with the same or very similar title
  - Pages sharing 3+ tags with what you're about to write
- If overlapping pages found, ask:
  > "Similar page already exists: [[X]] (overlapping tags: [...]).
  > Options: (a) update existing page, (b) create a new page for a distinct sub-topic, (c) merge"
- Then ask which perspective(s) to emphasize. Allowed values: `systems`, `practitioner`, `theory`, `history`, `interview`, `math` (multiple allowed).
- Wait for the user's response before proceeding.

### Step 4 — Write source page

Create `LLM Wiki/wiki/sources/<slug>-source.md`:
- Frontmatter: type=source, author, added (today), domain, source_url, source_file (path to raw file), status=summarized
- Body: 핵심 주장, 유저 관점 반영한 내 메모, ## 관련 section with [[wikilinks]]
- `[[wikilinks]]` go in body only, never in frontmatter

### Step 5 — Update concept/entity pages

For each key concept or entity in the source:
- If `LLM Wiki/wiki/<domain>/<concept>.md` exists → update it (note contradictions explicitly)
- If it doesn't exist → create it as `wiki/<domain>/<slug>.md` with frontmatter: type=concept, domain, tags, **perspective** (auto-inferred in quick mode; user-chosen in discuss mode), updated (today), status=draft

A single source can touch 10-15 pages.

### Step 6 — Update _meta/

Update `LLM Wiki/_meta/index.md`: add new pages with link + one-line summary.

Append to `LLM Wiki/_meta/log.md`:
```
## [YYYY-MM-DD] ingest (quick|discuss) | <source title>
생성/수정한 페이지: page1, page2, ...
```
- Tag the entry with `(quick)` or `(discuss)` so the user can later filter for review.

If Step 3 (discuss mode only) resulted in a **structural choice** (merge, split, new domain, new frontmatter field), append to `LLM Wiki/_meta/decisions.md`:
```
## [YYYY-MM-DD]: <decision title>
- **맥락**: <why this came up>
- **결정**: <what was decided>
- **영향**: <what changed>
- **대안**: <alternatives considered and why rejected>
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
- Wiki page exists AND `status: stable` → read wiki only (trusted knowledge)
- Wiki page exists BUT `status: draft` → read wiki AND the raw source file (`source_file` in frontmatter) to cross-check. Draft pages may contain errors.
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
2.5. **Semantic overlap** — For each domain, find concept page pairs sharing 3 or more tags. Report as potential duplicates or merge candidates. Example: "hash.md and binary-search-tree.md share tags [search, O(1), index] — consider if they need clearer distinction or cross-referencing."
3. Find pages that no other page links to (inbound orphans)
4. Find pages with `status: draft` that haven't been updated in a long time
4.5. **Unlinked mentions** — For each concept page title (and common aliases), search plain-text occurrences in other wiki pages that are NOT wrapped in `[[...]]`. Report as missing link opportunities. Example: "The word 'deadlock' appears in 3 pages without a wikilink to [[deadlock]]."
5. Find contradictions between concept pages
6. Identify data gaps — suggest new questions to investigate and new sources to add

Append to `LLM Wiki/_meta/log.md`:
```
## [YYYY-MM-DD] lint
발견한 문제: ...
제안된 다음 소스: ...
```

If lint results in a **structural recommendation that gets acted upon** (schema change, merge/split decision, new rule), append to `LLM Wiki/_meta/decisions.md` using the same format as INGEST Step 6.

---

## REVIEW flow

For inspecting and refining wiki pages — assigning perspective, promoting status, fixing content. Works on any wiki page, not just quick-mode pages.

### `/pocket-wiki review` (no argument)

List pages that may need review, in this priority order:

1. **Recently quick-ingested pages** (last 7 days) — verify the auto-inferred perspective is correct
2. **Stable pages** with `> ⚠️ Contradiction:` blockquotes still present (need resolution)
3. **Drafts** older than 30 days that haven't been promoted
4. **Pages updated by recent ingest** that previously had `status: stable` — content drift may have introduced inaccuracies

For each page, show: slug · status · perspective · domain · updated date · last source.

Then ask the user which page(s) to review.

### `/pocket-wiki review <argument>`

Argument resolution:
- If it matches a page slug exactly → enter interactive review for that page
- If it matches a domain folder name (e.g. `network`, `data-structures`) → list reviewable pages in that domain
- Otherwise → fuzzy-match against page slugs and offer suggestions

### Interactive review for a single page

1. Read the page and any linked `<slug>-source.md` files for context
2. Show a brief summary: current frontmatter + 2–3 sentence content recap
3. Ask the user what to change, in this order (skip if not applicable):
   - **Perspective** — assign or change `perspective` field. Allowed: `systems`, `practitioner`, `theory`, `history`, `interview`, `math`
   - **Status** — promote or change: `draft` → `stable` (reviewed and trusted) or `stable` → `archived` (outdated/superseded)
   - **Tags** — add/remove tags
   - **Content** — apply edits the user dictates (e.g. resolve a contradiction, add a section)
4. Update the page's `updated` field to today
5. Append to `LLM Wiki/_meta/log.md`:
   ```
   ## [YYYY-MM-DD] review | <slug>
   변경 사항: <comma-separated list of what changed>
   ```

If the review involves a **structural decision** (e.g. promoting a page to stable establishes a new precedent, or resolving a contradiction sets a rule), also append to `_meta/decisions.md`.

---

## DECISIONS flow

Read `LLM Wiki/_meta/decisions.md` before doing anything else.

### `/pocket-wiki decisions` (no subcommand)

Display all decisions in reverse chronological order. Summarize in a readable format:
- Date + title
- One-line summary of what was decided and why

Ask if the user wants to add a new decision or review a specific one in detail.

### `/pocket-wiki decisions add <title>`

Guide the user through recording a new structural decision interactively:
1. Ask: **맥락** — 이 결정이 왜 필요했나?
2. Ask: **결정** — 무엇을 어떻게 하기로 했나?
3. Ask: **영향** — 기존 페이지나 워크플로우에 어떤 변화가 생기나?
4. Ask: **대안** — 고려했다가 기각한 방법이 있나? (없으면 생략 가능)

Then append to `LLM Wiki/_meta/decisions.md`:
```
## [YYYY-MM-DD]: <title>
- **맥락**: ...
- **결정**: ...
- **영향**: ...
- **대안**: ... (있을 때만)
```

---

## Rules

- Never modify files in `raw/`, `graphify-out/`, or `LLM Wiki/graph/`
- Quick mode is the default — proceed without blocking the user. Use `discuss` mode only when explicitly invoked.
- `[[wikilinks]]` in body `## 관련` section only — never in frontmatter
- If graph.json doesn't exist, tell the user to run `/pocket-wiki <source>` first
