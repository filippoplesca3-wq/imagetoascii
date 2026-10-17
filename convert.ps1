param([string]$ImagePath)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Fail($msg) {
    Write-Host ""
    Write-Host "  $msg" -ForegroundColor Red
    Write-Host ""
    Read-Host "  Press Enter to close"
    exit 1
}

# No argument -> ask the user for a file
if (-not $ImagePath) {
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title    = "Pick an image to convert to ASCII"
    $dlg.Filter   = "Images|*.jpg;*.jpeg;*.png;*.webp;*.gif;*.bmp|All files|*.*"
    if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
    $ImagePath = $dlg.FileName
}

if (-not (Test-Path -LiteralPath $ImagePath)) { Fail "File not found: $ImagePath" }

$name = [System.IO.Path]::GetFileNameWithoutExtension($ImagePath)
$samples = Join-Path $root "samples"
if (-not (Test-Path $samples)) { New-Item -ItemType Directory -Path $samples | Out-Null }
$outPng = Join-Path $samples "$name-ascii.png"
$outTxt = Join-Path $samples "$name-ascii.txt"

Write-Host ""
Write-Host "  Converting `"$name`" ..." -ForegroundColor Cyan
Write-Host ""

# 1. Plain ASCII to a text file
& python (Join-Path $root "model-training\single_test.py") $ImagePath --cols 170 -o $outTxt
if ($LASTEXITCODE -ne 0) { Fail "single_test.py failed. Check that pillow, numpy and onnxruntime are installed." }

# 2. Same result as a viewable PNG
& python (Join-Path $root "model-training\render_ascii.py") $ImagePath --cols 170 --font-size 13 --theme "Classic B&W" -o $outPng
if ($LASTEXITCODE -ne 0) { Fail "render_ascii.py failed." }

Write-Host ""
Write-Host "  Saved: $outTxt" -ForegroundColor DarkGray
Write-Host "  Saved: $outPng" -ForegroundColor DarkGray
Write-Host ""

Start-Process $outPng
Read-Host "  Press Enter to close"