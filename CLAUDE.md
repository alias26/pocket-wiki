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
    │   ├── sources/        소스별 요약 페이지 (파일명: <slug>-source.md)
    │   └── <domain>/       개념/엔티티 페이지 (파일명: <slug>.md)
    └── _meta/
        ├── index.md        전체 wiki 목록 (ingest마다 업데이트)
        ├── log.md          작업 기록 (append-only) — 무엇을 했는가
        ├── decisions.md    구조적 결정 이력 (ADR) — 왜 이렇게 됐는가
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
source_file:
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
perspective: []   # optional: [systems, practitioner, theory, history, interview, math]
updated: YYYY-MM-DD
status: draft | stable | archived
---
```

- `[[wikilinks]]`는 frontmatter가 아닌 본문 `## 관련` 섹션에 작성
- `graph/` 파일은 Graphify가 자동 생성 — 절대 수정하지 않음
- `perspective`는 이 페이지가 어떤 시각으로 작성됐는지 명시 (복수 가능)

## INGEST

유저가 소스 이름이나 URL을 주면 아래 순서를 전부 처리한다.
유저는 한 마디만 하면 된다: "X 추가해줘" 또는 "X ingest해줘"

### 1. 소스 수집

URL이 주어진 경우:
```
python -m graphify add <url> --dir raw/crawled
```

제목/키워드만 주어진 경우: 웹에서 적절한 URL을 찾아서 위 명령 실행.
파일인 경우: `raw/files/`에 복사 안내.

### 2. 그래프 업데이트

```
graphify 스킬 호출: /graphify <POCKET_ROOT>/raw --update
```

### 3. 유저와 핵심 포인트 논의

소스를 읽고 바로 wiki를 작성하지 않는다.

**관점 논의 전에**, 같은 domain에서 태그가 3개 이상 겹치거나 제목이 유사한 기존 페이지가 있는지 먼저 확인한다.
있으면 유저에게 알린다: "유사한 페이지가 이미 있음: [[X]] (겹치는 태그: [...]) — 기존 페이지 업데이트 / 별도 페이지 생성 / 병합 중 선택"

그 다음 핵심 주장과 흥미로운 점을 공유하고, 강조할 관점(perspective)을 물어본다.
허용 값: `systems`, `practitioner`, `theory`, `history`, `interview`, `math` (복수 가능)
유저의 방향을 반영해서 이후 페이지를 작성한다.

### 4. source 페이지 작성

`wiki/sources/<slug>-source.md` 생성:
- 소스의 핵심 주장 요약
- 유저 관점과 내 메모 포함
- frontmatter: type=source
- 하나의 소스가 10-15개 wiki 페이지를 터치할 수 있음

### 5. concept/entity 페이지 업데이트

소스에서 등장한 개념과 엔티티를 확인한다.
- 기존 페이지가 있으면 업데이트 (새 데이터가 기존 내용과 모순되면 명시)
- 없으면 `wiki/<domain>/<개념>.md` 새로 생성
- frontmatter: type=concept, **perspective** (Step 3에서 유저와 논의한 값)

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

Step 3에서 **구조적 결정**이 발생한 경우(병합/분리/새 도메인/새 frontmatter 필드 등) `_meta/decisions.md`에도 추가:
```
## [YYYY-MM-DD]: <결정 제목>
- **맥락**: 왜 필요했나
- **결정**: 무엇을 어떻게
- **영향**: 어떤 변화가 생기나
- **대안**: 기각한 방법 (있을 때만)
```

## QUERY

유저가 질문하면 아래 순서로 처리한다.

### 1. 그래프 탐색

```
python -m graphify query "<질문>" --budget 2000
```

관련 노드를 파악한다. 무엇을 읽을지 찾아주는 네비게이터 역할이다.

### 2. wiki 페이지 또는 raw 파일 읽기

- wiki 있고 `status: stable` → wiki만 읽기 (신뢰된 지식)
- wiki 있고 `status: draft` → wiki + raw 같이 읽기 (draft는 오류 가능성 있음)
- wiki 없음 → raw 파일 읽기

### 3. 답변 + 없으면 ingest

답변한다. raw 파일을 읽었다면 동시에 wiki 페이지를 작성한다 (INGEST 4-6단계).
다음 번 같은 주제가 나오면 wiki가 준비되어 있다.

비교표, 분석, 새로 발견한 연결 등 가치 있는 답변도 wiki 페이지로 저장한다.

log.md에 기록:
```
## [YYYY-MM-DD] query | 질문 요약
답변 저장 위치: wiki/domain/page.md (저장한 경우)
```

## LINT

유저가 요청하면 wiki 상태를 점검한다.

1. `_meta/index.md`와 실제 파일 목록 대조 — 누락/불일치 확인
2. 본문에서 참조되지만 페이지가 없는 `[[wikilinks]]` 확인 (아웃바운드 고아)
2.5. **의미적 중복** — 같은 domain에서 태그 3개 이상 겹치는 페이지 쌍 탐지 (병합/구분 후보)
3. 다른 페이지에서 링크되지 않는 페이지 확인 (인바운드 고아)
4. `status: draft`가 오래된 페이지 확인
4.5. **누락 링크** — concept 페이지 제목이 다른 페이지 본문에 일반 텍스트로 등장하지만 `[[...]]`로 감싸지 않은 경우 탐지
5. concept 페이지 간 모순 확인
6. 데이터 갭 파악 → 조사할 질문과 찾아볼 소스 제안

log.md에 기록:
```
## [YYYY-MM-DD] lint
발견한 문제: ...
제안된 다음 소스: ...
```

lint 결과로 **구조적 변경**(스키마 수정, 페이지 병합/분리, 새 규칙 추가)이 발생한 경우 `_meta/decisions.md`에도 기록한다.

## DECISIONS

`/pocket-wiki decisions` 또는 `/pocket-wiki decisions add <제목>` 으로 호출한다.

### 조회 (`decisions`)

`_meta/decisions.md`를 읽어 전체 결정 이력을 역순으로 표시한다. 각 항목은 날짜 + 제목 + 한줄 요약으로 정리한다.
추가 여부를 물어본다.

### 기록 (`decisions add <제목>`)

아래 순서로 질문하며 안내형으로 기록한다:
1. **맥락** — 이 결정이 왜 필요했나?
2. **결정** — 무엇을 어떻게 하기로 했나?
3. **영향** — 기존 페이지나 워크플로우에 어떤 변화가 생기나?
4. **대안** — 고려했다가 기각한 방법이 있나? (없으면 생략)

`_meta/decisions.md`에 추가:
```
## [YYYY-MM-DD]: <제목>
- **맥락**: ...
- **결정**: ...
- **영향**: ...
- **대안**: ... (있을 때만)
```

## 절대 하지 않는 것

- `raw/` 파일 수정 또는 삭제
- `graphify-out/` 파일 수정
- `graph/` 폴더 파일 수정
- 유저와 논의 없이 바로 wiki 작성
