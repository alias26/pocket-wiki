---
type: meta
---

# Wiki Decisions

History of structural and editorial decisions you made *while writing the wiki* — not changes to the pocket-wiki tool itself.

This file answers: "Why is the wiki organized this way?" — page splits, page merges, domain boundaries, naming conventions, contradiction resolutions, status promotions you want to remember.

For changes to the pocket-wiki tool itself (skill behavior, schema fields, lint rules), use git history instead.

---

## Examples of what belongs here

```
## [YYYY-MM-DD]: Split tcp-ip into tcp and ip pages
- **Context**: The combined page grew past 600 lines and mixed transport-layer
  details with internet-layer routing concepts
- **Decision**: Split into wiki/network/tcp.md and wiki/network/ip.md.
  Cross-link in each page's Related section
- **Impact**: tcp-ip.md archived. Inbound links updated
- **Alternatives**: Keep combined with H2-level subdivisions (rejected — too long
  for a single concept page)

## [YYYY-MM-DD]: Resolve contradiction in attention.md (paper vs blog)
- **Context**: Vaswani 2017 says X about scaling, blog post Y says X' which
  contradicts on the constant factor
- **Decision**: Take the paper's value as canonical. Note the blog's claim as
  a footnote with citation
- **Impact**: attention.md updated. Blog source page status set to `superseded`

## [YYYY-MM-DD]: Promote hash.md to stable
- **Context**: Reviewed against 3 sources. No contradictions. Tags settled
- **Decision**: status: draft → stable
- **Impact**: hash.md will now be served wiki-only on QUERY (no raw cross-check)
```

---

<!-- Add new entries below, newest first -->
