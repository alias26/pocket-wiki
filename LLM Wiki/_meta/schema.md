---
type: meta
---

# Wiki Page Schema

## Source 페이지 (wiki/sources/)

```yaml
---
title:
type: source
author:
added: YYYY-MM-DD
domain:
source_url:
source_file:
status: summarized
---
```

## Concept 페이지 (wiki/<domain>/)

```yaml
---
title:
type: concept
domain:
tags: []
updated: YYYY-MM-DD
status: draft | stable | archived
---
```

## 운영 규칙

1. raw/ 소스는 절대 수정하지 않는다
2. graph/ 폴더는 Graphify 전용 - 수정하지 않는다
3. [[wikilinks]]는 frontmatter가 아닌 본문 ## 관련 섹션에 작성
4. wiki/ 페이지 생성/수정 시 _meta/log.md에 기록
