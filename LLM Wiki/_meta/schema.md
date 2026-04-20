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
status: summarized | reviewed | superseded
---
```

## Concept 페이지 (wiki/<domain>/)

```yaml
---
title:
type: concept
domain:
tags: []
perspective: []   # optional — 이 페이지가 어떤 관점으로 쓰였는지
updated: YYYY-MM-DD
status: draft | stable | archived
---
```

### `perspective` 허용 값

| 값 | 의미 |
|---|---|
| `systems` | 내부 동작·메모리·OS·하드웨어 관점 |
| `practitioner` | 실무 적용·툴·코드 관점 |
| `theory` | 수학·알고리즘·복잡도·증명 관점 |
| `history` | 기술 진화·계보·버전 비교 관점 |
| `interview` | 면접 Q&A·빈출 포인트 관점 |
| `math` | 수식·통계·확률 관점 |

여러 개 조합 가능 (예: `[systems, practitioner]`).
관점을 명시하면 나중에 "실무 관점으로 정리된 노드만 복습" 같은 필터가 가능.

## 운영 규칙

1. raw/ 소스는 절대 수정하지 않는다
2. graph/ 폴더는 Graphify 전용 - 수정하지 않는다
3. [[wikilinks]]는 frontmatter가 아닌 본문 ## 관련 섹션에 작성
4. wiki/ 페이지 생성/수정 시 _meta/log.md에 기록
5. concept 페이지 작성 시 perspective 필드를 채운다 (optional이지만 권장)
