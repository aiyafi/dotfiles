# CAMTRO - ASCII WEBCAM By K9Fox

function camtro {
    param(
        [switch]$help,
        [switch]$color,
        [int]$width = 120
    )

    if ($help) {
        Write-Host "`n🎥 CAMTRO - ASCII Webcam`n" -ForegroundColor Cyan
        Write-Host "Usage:" -ForegroundColor White
        Write-Host "  camtro               - Start ASCII webcam (grayscale)" -ForegroundColor Gray
        Write-Host "  camtro -color        - Start with RGB colors (TRUE COLOR!)" -ForegroundColor Gray
        Write-Host "  camtro -width 80     - Custom width (default: 120)" -ForegroundColor Gray
        Write-Host "  camtro -color -w 100 - Color mode with custom width" -ForegroundColor Gray
        Write-Host "  camtro -help         - Show this help`n" -ForegroundColor Gray
        Write-Host "Controls:" -ForegroundColor White
        Write-Host "  Ctrl+C               - Stop camera`n" -ForegroundColor Gray
        Write-Host "Pro Tips:" -ForegroundColor Yellow
        Write-Host "  • Color mode uses more resources but looks amazing!" -ForegroundColor Gray
        Write-Host "  • Smaller width = faster performance" -ForegroundColor Gray
        Write-Host "  • Works best in dark mode terminal`n" -ForegroundColor Gray
        return
    }

    $scriptPath = "$env:USERPROFILE\.App\pwsh\scripts\ascii_cam.py"

    # Check py
    try {
        $pythonVersion = python -V 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Python not found!" -ForegroundColor Red
            Write-Host "Install Python from: https://www.python.org/downloads/" -ForegroundColor Yellow
            return
        }
    }
    catch {
        Write-Host "❌ Python not found!" -ForegroundColor Red
        return
    }

    # Check opencv
    Write-Host "🔍 Checking dependencies..." -ForegroundColor Cyan
    $opencvCheck = python -c "import cv2" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "📦 OpenCV not installed. Installing..." -ForegroundColor Yellow
        Write-Host "This might take a minute..." -ForegroundColor Gray
        python -m pip install opencv-python --quiet

        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install OpenCV" -ForegroundColor Red
            Write-Host "Try manually: pip install opencv-python" -ForegroundColor Yellow
            return
        }
        Write-Host "✓ OpenCV installed!" -ForegroundColor Green
    }

    # Check 
    if (!(Test-Path $scriptPath)) {
        Write-Host "❌ Script not found: $scriptPath" -ForegroundColor Red
        Write-Host "Make sure ascii_cam.py is in the scripts folder" -ForegroundColor Yellow
        return
    }

    $args = @()
    if ($color) {
        $args += "--color"
        Write-Host "🎨 RGB Color mode enabled!" -ForegroundColor Magenta
    }
    if ($width -ne 120) {
        $args += "--width", $width
    }

    # Run script
    Write-Host "🚀 Starting Camtro..." -ForegroundColor Green
    python $scriptPath @args
}
