#!/bin/bash
# pocket-wiki setup (Mac/Linux)

echo "pocket-wiki 설치 시작..."

# 1. graphify 설치
echo ""
echo "[1/4] graphify 설치..."
pip install graphifyy -q || pip3 install graphifyy -q
if [ $? -ne 0 ]; then echo "graphify 설치 실패. pip이 설치되어 있는지 확인하세요."; exit 1; fi

# 2. Claude Code 스킬 등록
echo "[2/4] Claude Code 스킬 등록..."
graphify install --platform claude

# 3. 폴더 구조 생성
echo "[3/4] 폴더 구조 생성..."
mkdir -p raw/files raw/crawled graphify-out
mkdir -p "LLM Wiki/graph"
mkdir -p "LLM Wiki/wiki/sources"
mkdir -p "LLM Wiki/_meta"
echo "폴더 생성 완료"

# 4. 안내
echo ""
echo "[4/4] 완료!"
echo ""
echo "다음 단계:"
echo "  1. Obsidian에서 'LLM Wiki/' 폴더를 vault로 열기"
echo "  2. Community Plugins > Local REST API 플러그인 설치 및 활성화"
echo "  3. 이 디렉토리에서 Claude Code 실행:"
echo "       cd $(pwd)"
echo "       claude"
echo ""
echo "소스 추가:"
echo "  graphify add <url> --dir raw/crawled"
echo ""
echo "wiki 빌드:"
echo "  대화창에서 'graphify로 raw/ 처리해줘' 라고 Claude에게 요청"
