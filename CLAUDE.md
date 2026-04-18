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
    │   └── <domain>/       개념/엔티티 페이지 (ml, systems, tools 등)
    └── _meta/
        ├── index.md        전체 wiki 목록 (ingest마다 업데이트)
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
python -m graphify add <url> --dir raw/crawled
```

파일 추가: `raw/files/`에 직접 복사

### 2. Graphify 실행

```
python -m graphify --update
```

graph.json과 graph/ 노드 파일이 자동 업데이트된다.

### 3. 유저와 핵심 포인트 논의

소스를 읽고 바로 작성하지 않는다.
먼저 유저에게 핵심 주장, 흥미로운 점, 강조할 부분을 물어본다.
유저의 관점을 반영해서 이후 페이지를 작성한다.

### 4. source 페이지 작성

`wiki/sources/<제목>.md` 를 생성한다.
- 소스의 핵심 주장 요약
- 내 메모와 관점 포함
- frontmatter: type=source
- 하나의 소스가 10-15개 wiki 페이지를 터치할 수 있음

### 5. concept/entity 페이지 업데이트

소스에서 등장한 개념과 엔티티를 확인한다.
- 기존 페이지가 있으면 업데이트 (새 데이터가 기존 내용과 모순되면 명시)
- 없으면 `wiki/<domain>/<개념>.md` 새로 생성
- frontmatter: type=concept

### 6. _meta/ 업데이트

```
_meta/index.md — 새 페이지 목록에 추가 (링크 + 한줄 요약 + 메타데이터)
_meta/log.md   — 작업 기록 추가
```

log.md 포맷 (grep으로 파싱 가능하게):
```
## [YYYY-MM-DD] ingest | 소스명
생성/수정한 페이지: page1, page2, ...
```

## QUERY

지식을 검색하고 답변할 때 순서대로 실행한다.

### 1. index.md 먼저 읽기

항상 `_meta/index.md`를 먼저 읽어서 관련 페이지를 찾는다.
이것이 기본 탐색 방법이다.

### 2. 그래프 탐색 (보완)

```
python -m graphify query "<질문>" --budget 2000
```

index.md에서 찾지 못한 연결을 그래프에서 추가로 확인한다.

### 3. wiki 페이지 읽기

찾은 관련 페이지들을 읽고 답변을 합성한다.

### 4. 답변 + wiki에 저장

답변한다. 그리고 반드시 판단한다:
- 비교표, 분석, 새로 발견한 연결, 인사이트 — 이런 좋은 답변은 **항상** wiki 페이지로 저장한다
- `wiki/<domain>/` 에 synthesis 페이지로 작성
- 이렇게 탐색 자체가 지식으로 쌓인다

log.md에 기록:
```
## [YYYY-MM-DD] query | 질문 요약
답변 저장 위치: wiki/domain/page.md (저장한 경우)
```

## LINT

주기적으로 wiki 상태를 점검한다.

1. `_meta/index.md`와 실제 파일 목록 대조 — 누락/불일치 확인
2. 본문에서 참조되지만 페이지가 없는 `[[wikilinks]]` 확인 (아웃바운드 고아)
3. 다른 페이지에서 링크되지 않는 페이지 확인 (인바운드 고아)
4. `status: draft`가 오래된 페이지 확인
5. concept 페이지 간 모순 확인
6. 새로 채울 수 있는 데이터 갭 파악 → 조사할 질문과 찾아볼 소스 제안

log.md에 기록:
```
## [YYYY-MM-DD] lint
발견한 문제: ...
제안된 다음 소스: ...
```

## 절대 하지 않는 것

- `raw/` 파일 수정 또는 삭제
- `graphify-out/` 파일 수정
- `graph/` 폴더 파일 수정
- 유저와 논의 없이 바로 ingest 작성
