# pocket-wiki

Graphify + LLM Wiki 패턴을 결합한 개인 지식 베이스.
raw 소스를 지식 그래프로 변환하고, 인간이 읽을 수 있는 wiki 페이지로 컴파일한다.

## 구조

```
<root>/
├── raw/                    원본 소스 (절대 수정하지 않음)
│   ├── files/              직접 추가한 파일
│   └── crawled/            웹에서 수집한 파일
├── graphify-out/           Graphify 출력 (절대 수정하지 않음)
│   ├── graph.json          영속 지식 그래프
│   └── GRAPH_REPORT.md
└── LLM Wiki/               Obsidian vault
    ├── graph/              Graphify --obsidian 자동 출력 (절대 수정하지 않음)
    ├── wiki/
    │   ├── sources/        소스별 요약 페이지 (ingest마다 1개)
    │   └── <domain>/       개념 페이지 (ml, systems, tools 등)
    └── _meta/
        ├── index.md        전체 wiki 목록 (자동 업데이트)
        ├── log.md          작업 기록 (append-only)
        └── schema.md       frontmatter 규칙
```

## Frontmatter 규칙

**source 페이지** (`wiki/sources/`):
```yaml
---
title:
type: source
author:
added: YYYY-MM-DD
domain:
source_url:
status: summarized
---
```

**concept 페이지** (`wiki/<domain>/`):
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

- `[[wikilinks]]`는 frontmatter가 아닌 본문 `## 관련` 섹션에 작성
- `graph/` 파일은 Graphify가 자동 생성 — 절대 수정하지 않음

## INGEST

새 소스를 추가할 때 순서대로 실행한다.

### 1. raw/ 에 소스 추가

URL 수집:
```
/graphify add <url> --dir ../raw/crawled
```

파일 추가: `raw/files/`에 직접 복사

### 2. Graphify 실행

```
/graphify ../raw --obsidian --obsidian-dir "LLM Wiki/graph"
```

`LLM Wiki/`를 working directory로 실행한다.
graph.json과 graph/ 노드 파일이 자동 업데이트된다.

### 3. source 페이지 작성

`wiki/sources/<제목>.md` 를 생성한다.
- 소스의 핵심 주장 요약
- 내 메모와 관점 포함
- frontmatter: type=source

### 4. concept 페이지 업데이트

소스에서 등장한 개념들을 확인한다.
- 기존 페이지가 있으면 업데이트
- 없으면 `wiki/<domain>/<개념>.md` 새로 생성
- frontmatter: type=concept

### 5. _meta/ 업데이트

```
_meta/index.md — 새 페이지 목록에 추가
_meta/log.md   — 작업 기록 추가 (날짜 | ingest | 소스명 | 생성/수정 페이지)
```

## QUERY

지식을 검색하고 답변할 때 순서대로 실행한다.

### 1. 그래프 탐색 (빠른 필터)

```
/graphify query "<질문>" --budget 2000
```

관련 노드를 확인한다.

### 2. wiki 페이지 읽기

그래프에서 찾은 노드와 연결된 `wiki/` 페이지를 읽는다.
`_meta/index.md`로 관련 페이지를 찾아도 된다.

### 3. 답변

wiki 페이지 기반으로 답변한다.
새로운 인사이트가 생기면 synthesis 페이지로 `wiki/<domain>/`에 저장한다.

## LINT

주기적으로 wiki 상태를 점검한다.

1. `_meta/index.md`와 실제 파일 목록 대조 — 누락/불일치 확인
2. 본문에서 참조되지만 페이지가 없는 `[[wikilinks]]` 확인
3. `status: draft`가 오래된 페이지 확인
4. concept 페이지 간 모순 확인

## 절대 하지 않는 것

- `raw/` 파일 수정 또는 삭제
- `graphify-out/` 파일 수정
- `graph/` 폴더 파일 수정
- `_meta/index.md`를 수동으로 편집하지 않음 (LLM이 관리)
