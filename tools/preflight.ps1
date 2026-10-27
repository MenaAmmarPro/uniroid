param(
  [switch]$SkipAnalyze,
  [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

Push-Location $root
try {
  Write-Host "==> flutter pub get" -ForegroundColor Cyan
  flutter pub get

  if (-not $SkipAnalyze) {
    Write-Host "==> flutter analyze" -ForegroundColor Cyan
    flutter analyze
  }

  Write-Host "==> flutter test" -ForegroundColor Cyan
  flutter test

  Write-Host "==> flutter build apk --release" -ForegroundColor Cyan
  flutter build apk --release

  $apk = Join-Path $root "build\app\outputs\flutter-apk\app-release.apk"
  if (-not (Test-Path $apk)) { throw "APK not found: $apk" }

  if (-not $SkipInstall) {
    $adb = Get-Command adb -ErrorAction SilentlyContinue
    if ($adb) {
      $devices = & adb devices | Select-String "device$"
      if ($devices) {
        Write-Host "==> adb install" -ForegroundColor Cyan
        & adb install -r $apk
        Write-Host "==> launching app" -ForegroundColor Cyan
        & adb shell am start -n "com.menaammarpro.uniroid/.MainActivity" | Out-Null
      } else {
        Write-Host "No device connected; skipping install." -ForegroundColor Yellow
      }
    } else {
      Write-Host "adb not found; skipping install." -ForegroundColor Yellow
    }
  }

  Write-Host "PREFLIGHT OK" -ForegroundColor Green
} finally {
  Pop-Location
}
