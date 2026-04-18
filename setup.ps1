# pocket-wiki setup (Windows)

Write-Host "Setting up pocket-wiki..." -ForegroundColor Cyan

# 1. Install graphify
Write-Host ""
Write-Host "[1/4] Installing graphify..."
pip install graphifyy -q
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install graphify. Make sure pip is installed." -ForegroundColor Red
    exit 1
}

# 2. Register Claude Code skill
Write-Host "[2/4] Registering Claude Code skill..."
python -m graphify install --platform claude

# 3. Create folder structure
Write-Host "[3/4] Creating folder structure..."
New-Item -ItemType Directory -Force -Path "raw\files" | Out-Null
New-Item -ItemType Directory -Force -Path "raw\crawled" | Out-Null
New-Item -ItemType Directory -Force -Path "graphify-out" | Out-Null
New-Item -ItemType Directory -Force -Path "LLM Wiki\graph" | Out-Null
New-Item -ItemType Directory -Force -Path "LLM Wiki\wiki\sources" | Out-Null
New-Item -ItemType Directory -Force -Path "LLM Wiki\_meta" | Out-Null
Write-Host "Folders created."

# 4. Done
Write-Host ""
Write-Host "[4/4] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open 'LLM Wiki/' as your Obsidian vault"
Write-Host "  2. Install 'Local REST API' community plugin and enable it"
Write-Host "  3. Run Claude Code from this directory:"
Write-Host "       cd $(Get-Location)"
Write-Host "       claude"
Write-Host ""
Write-Host "Add a source:"
Write-Host "  python -m graphify add [url] --dir raw/crawled"
Write-Host ""
Write-Host "Build wiki:"
Write-Host "  Tell Claude: 'ingest [source name]'"
