param()
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  git config core.hooksPath .githooks
  Write-Host "Hooks installed. Use --no-verify to bypass." -ForegroundColor Green
} finally {
  Pop-Location
}
