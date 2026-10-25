
param(
    [string]$InputDirectory = ".",
    [string]$OutputDirectory = "",

    # Drehung im Uhrzeigersinn in Grad (0 = keine Drehung)
    [ValidateSet(0, 90, 180, 270)]
    [int]$Rotate = 0
)

$ErrorActionPreference = "Stop"

# ImageMagick prüfen
$MagickCommand = Get-Command "magick" -ErrorAction SilentlyContinue

if (-not $MagickCommand) {
    Write-Error "ImageMagick wurde nicht gefunden. Bitte Installation und PATH prüfen."
    exit 1
}

# Eingabeverzeichnis prüfen
if (-not (Test-Path -LiteralPath $InputDirectory -PathType Container)) {
    Write-Error "Eingabeverzeichnis nicht gefunden: $InputDirectory"
    exit 1
}

$InputDirectory = (Resolve-Path -LiteralPath $InputDirectory).Path

# Ausgabeverzeichnis festlegen
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = $InputDirectory
}
else {
    if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force |
            Out-Null
    }

    $OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
}

# TIFF-Dateien suchen
$TifFiles = @(
    Get-ChildItem -LiteralPath $InputDirectory -File |
        Where-Object {
            $_.Extension -match '^\.(tif|tiff)$'
        }
)

if ($TifFiles.Count -eq 0) {
    Write-Host "Keine TIFF-Dateien gefunden."
    exit 0
}

$SuccessCount = 0
$ErrorCount = 0

foreach ($File in $TifFiles) {
    $OutputFile = Join-Path $OutputDirectory ($File.BaseName + ".pdf")

    Write-Host "Konvertiere: $($File.Name)"

    # ImageMagick-Argumente aufbauen
    $MagickArgs = @($File.FullName)

    if ($Rotate -ne 0) {
        $MagickArgs += @("-rotate", $Rotate)
    }

    $MagickArgs += @("-compress", "Zip", $OutputFile)

    try {
        & $MagickCommand.Source @MagickArgs

        if ($LASTEXITCODE -ne 0) {
            throw "ImageMagick meldet den Fehlercode $LASTEXITCODE."
        }

        if (-not (Test-Path -LiteralPath $OutputFile -PathType Leaf)) {
            throw "Die PDF-Datei wurde nicht erstellt."
        }

        Write-Host "Erfolgreich: $OutputFile" -ForegroundColor Green
        $SuccessCount++
    }
    catch {
        Write-Warning "Fehler bei $($File.Name): $_"
        $ErrorCount++
    }
}

Write-Host ""
Write-Host "Konvertierung abgeschlossen."
Write-Host "Erfolgreich: $SuccessCount"
Write-Host "Fehler:      $ErrorCount"
Write-Host "Ausgabe:     $OutputDirectory"
