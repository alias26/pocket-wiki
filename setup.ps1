# pocket-wiki setup (Windows)

Write-Host "pocket-wiki 설치 시작..." -ForegroundColor Cyan

# 1. graphify 설치
Write-Host "`n[1/4] graphify 설치..."
pip install graphifyy -q
if ($LASTEXITCODE -ne 0) { Write-Host "graphify 설치 실패. pip이 설치되어 있는지 확인하세요." -ForegroundColor Red; exit 1 }

# 2. Claude Code 스킬 등록
Write-Host "[2/4] Claude Code 스킬 등록..."
graphify install --platform claude

# 3. 폴더 구조 생성
Write-Host "[3/4] 폴더 구조 생성..."
New-Item -ItemType Directory -Force -Path "raw/files" | Out-Null
New-Item -ItemType Directory -Force -Path "raw/crawled" | Out-Null
New-Item -ItemType Directory -Force -Path "graphify-out" | Out-Null
New-Item -ItemType Directory -Force -Path "LLM Wiki/graph" | Out-Null
New-Item -ItemType Directory -Force -Path "LLM Wiki/wiki/sources" | Out-Null
New-Item -ItemType Directory -Force -Path "LLM Wiki/_meta" | Out-Null
Write-Host "폴더 생성 완료"

# 4. 안내
Write-Host "`n[4/4] 완료!" -ForegroundColor Green
Write-Host @"

다음 단계:
  1. Obsidian에서 'LLM Wiki/' 폴더를 vault로 열기
  2. Community Plugins > Local REST API 플러그인 설치 및 활성화
  3. 이 디렉토리에서 Claude Code 실행:
       cd $(Get-Location)
       claude

소스 추가:
  graphify add <url> --dir raw/crawled

wiki 빌드:
  /graphify 대화창에서 입력 또는
  "graphify로 raw/ 처리해줘" 라고 Claude에게 요청
"@
