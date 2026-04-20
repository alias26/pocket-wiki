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

## Operating rules

1. Never modify sources in `raw/`
2. The `graph/` folder is Graphify-only — never modify
3. `[[wikilinks]]` belong in the body `## Related` section, not in frontmatter
4. Record every wiki page creation/update in `_meta/log.md`
5. Fill the `perspective` field when creating concept pages (optional but recommended)
