# pocket-wiki

Obsidian에서 살아있는 개인 지식 베이스. 소스를 추가할수록 스스로 성장하고, Claude로 질의 가능.

[Andrej Karpathy의 LLM Wiki 컨셉](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)에서 영감을 받았습니다.

[English README](README.md)

## 동작 원리

```
raw/              →   graphify --update   →   graphify-out/graph.json
(소스 파일)                                    (지식 그래프)

                  →   /pocket-wiki        →   LLM Wiki/wiki/
                      (Claude Code)           (사람이 읽는 wiki 페이지)
```

1. URL, PDF, 글 등 소스를 `raw/`에 넣음
2. [Graphify](https://github.com/safishamsi/graphify)가 소스에서 개념, 관계, "god node"(고연결 허브)를 추출해 지식 그래프를 만듦
3. Claude가 그래프로 관련 컨텍스트를 효율적으로 탐색하고, 선택한 관점으로 wiki 페이지를 작성
4. 다음 번 질문 시 Claude가 wiki를 먼저 읽음 — draft 페이지는 raw 소스와 교차 검증

## 사전 요구사항

- Python 3.9+
- [Obsidian](https://obsidian.md)
- [Claude Code](https://claude.ai/code)

**[Graphify](https://github.com/safishamsi/graphify)** (`pip install graphifyy`) — 문서, 코드, 논문, URL을 질의 가능한 지식 그래프로 변환합니다. setup 스크립트가 자동으로 설치합니다.

## 설치

**Mac/Linux**
```bash
bash setup.sh
```

**Windows**
```powershell
.\setup.ps1
```

setup 스크립트가 하는 일:
1. [Graphify](https://github.com/safishamsi/graphify) 설치 (`pip install graphifyy`)
2. `/pocket-wiki` 스킬을 Claude Code에 등록 (`~/.claude/`)
3. 폴더 구조 생성

이후:
1. `LLM Wiki/` 폴더를 Obsidian vault로 열기
2. **Local REST API** 커뮤니티 플러그인 설치 및 활성화
3. 이 디렉토리에서 `claude` 실행

## 사용법

### 소스 추가 및 wiki 작성
```
/pocket-wiki <url 또는 제목>           # quick 모드 (기본) — 논의 없이 자동 작성
/pocket-wiki discuss <url 또는 제목>   # 관점 논의 후 작성
```
**Quick 모드** (기본): Claude가 소스를 가져오고, 그래프를 업데이트하고, 대화 없이 wiki 페이지를 작성합니다. 페이지는 `status: draft`로 저장되며, **`perspective`는 소스 타입 기반으로 자동 추론**됩니다 (논문 → theory, 블로그 → practitioner 등). 대량 ingest에 적합.

**Discuss 모드**: Claude가 핵심 포인트를 공유하고, 강조할 관점을 묻고, 작성 전 확인합니다. 중요한 소스에 적합.

### 지식 질의
```
/pocket-wiki query <질문>
```
Claude가 wiki를 검색하고 답변합니다. wiki 페이지가 없으면 raw 소스를 읽고 즉시 작성합니다.

### 상태 점검
```
/pocket-wiki lint
```
깨진 wikilink, 고아 페이지, 의미적 중복(태그 3개 이상 겹침), 누락 링크 등을 검사합니다.

### 페이지 검토
```
/pocket-wiki review                   # 검토 후보 목록
/pocket-wiki review <slug 또는 domain>  # 특정 페이지나 도메인 검토
```
`perspective` 부여, `status` 승격 (draft → stable → archived), 태그/내용 수정. quick으로 ingest한 페이지를 읽고 승격할 때 특히 유용합니다.

### 결정 이력
```
/pocket-wiki decisions
/pocket-wiki decisions add <제목>
```
구조적 결정(스키마 변경, 페이지 병합/분리, 워크플로우 수정)을 ADR 형식으로 조회하거나 기록합니다.

## Concept 페이지 frontmatter

```yaml
---
title:
type: concept
domain:
tags: []
perspective: []   # optional: systems | practitioner | theory | history | interview | math
updated: YYYY-MM-DD
status: draft | stable | archived
---
```

`perspective`는 이 페이지가 어떤 관점으로 작성됐는지 기록합니다. 나중에 "network 도메인의 실무 관점 페이지만 복습" 같은 필터링이 가능해집니다.

## 폴더 구조

```
pocket-wiki/
├── raw/                 # 소스 파일 — 로컬 전용, 커밋되지 않음
│   ├── files/           # 직접 추가한 파일
│   └── crawled/         # /pocket-wiki가 가져온 파일
├── LLM Wiki/
│   ├── wiki/
│   │   ├── sources/     # 소스별 <slug>-source.md
│   │   └── <domain>/    # concept 페이지
│   └── _meta/
│       ├── schema.md    # frontmatter 규칙
│       ├── decisions.md # ADR — 왜 이렇게 됐는가
│       ├── index.md     # 전체 wiki 목록 (gitignore, 로컬 전용)
│       └── log.md       # 작업 기록 (gitignore, 로컬 전용)
├── graphify-out/        # graph.json — gitignore, 로컬 전용
├── CLAUDE.md            # Claude 워크플로우 지시
├── SKILL.md             # /pocket-wiki 스킬 정의
├── setup.sh
└── setup.ps1
```

## wiki 동기화

`raw/`, `graphify-out/`, `_meta/index.md`, `_meta/log.md`는 **의도적으로 gitignore** 처리되어 있습니다 — 개인 소스 파일과 브라우징 이력이 포함될 수 있기 때문입니다.

wiki 페이지와 그래프를 여러 기기에서 동기화하려면 **private** 레포에 push하세요:

```bash
git add "LLM Wiki/wiki/" graphify-out/
git commit -m "sync wiki"
git push
```

`raw/`는 의도적으로 로컬 전용입니다. 백업이 필요하면 rsync, Syncthing, 또는 private 클라우드 폴더를 사용하세요.

## 라이선스

[MIT](LICENSE)
