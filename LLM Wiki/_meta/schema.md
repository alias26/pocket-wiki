---
type: meta
---

# Wiki Page Schema

## Source pages (wiki/sources/)

```yaml
---
title:
type: source
author:
added: YYYY-MM-DD
domain:
source_url:
source_file:
status: summarized | reviewed | superseded
---
```

## Concept pages (wiki/<domain>/)

```yaml
---
title:
type: concept
domain:
tags: []
perspective: []   # optional — the angle this page was written from
updated: YYYY-MM-DD
status: draft | stable | archived
---
```

### `perspective` allowed values

| Value | Meaning |
|---|---|
| `systems` | Internals, memory, OS, hardware angle |
| `practitioner` | Real-world application, tools, code angle |
| `theory` | Math, algorithms, complexity, proofs angle |
| `history` | Tech evolution, lineage, version comparison |
| `interview` | Interview Q&A, frequently-asked angle |
| `math` | Equations, statistics, probability angle |

Multiple values can be combined (e.g. `[systems, practitioner]`).
Specifying perspective enables filters like "review only practitioner-perspective nodes" later on.

## Status transitions

State machines for the `status` field. Transitions are explicit and never silent — the tool may suggest, but the user always confirms.

### Concept pages: `draft | stable | archived`

```
draft ──── user review ────▶ stable
draft ──── archive ────────▶ archived
stable ─── new contradiction (suggested) ▶ draft
stable ─── archive ────────▶ archived
archived ─ manual revival via review ──▶ stable
```

| From | To | Trigger | Required |
|---|---|---|---|
| draft | stable | `/pocket-wiki review` confirms page | No unresolved `> ⚠️ Contradiction:` blockquotes; user explicit confirmation |
| draft | archived | User archives in review | User explicit confirmation |
| stable | draft | Ingest introduces contradiction with existing content | Tool flags, user confirms demotion |
| stable | archived | Page superseded by a newer/better page, or content outdated | User explicit confirmation |
| archived | stable | Revival via review | User explicit confirmation |

**Never auto-promote** to `stable`. Stable means "I have personally vouched for this." Auto-promotion would erode the trust signal.

### Source pages: `summarized | reviewed | superseded`

```
summarized ── user verifies summary ──▶ reviewed
reviewed ──── newer source replaces ──▶ superseded
```

| From | To | Trigger | Required |
|---|---|---|---|
| summarized | reviewed | User reads source page, confirms summary is accurate | User explicit confirmation via `/pocket-wiki review <slug>-source` |
| reviewed | superseded | User marks when a newer source replaces this one | User explicit confirmation; ideally point to the replacement source in the Related section |

### Logging

Every status change is logged to `_meta/log.md` with the reason:
```
## [YYYY-MM-DD] review | <slug>
status: draft → stable
reason: reviewed against 3 sources, no contradictions
```

## Operating rules

1. Never modify sources in `raw/`
2. The `graph/` folder is Graphify-only — never modify
3. `[[wikilinks]]` belong in the body `## Related` section, not in frontmatter
4. Record every wiki page creation/update in `_meta/log.md`
5. Fill the `perspective` field when creating concept pages (optional but recommended)
6. Status transitions follow the rules above — never auto-promote to `stable`
