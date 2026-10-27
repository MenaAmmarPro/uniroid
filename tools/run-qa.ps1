param()
$qa = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "uniroid-qa"
Push-Location $qa
try {
  python src/orchestrator.py
} finally {
  Pop-Location
}
