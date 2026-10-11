param([switch]$SkipInstaller, [switch]$SkipApplication)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$backupRoot = Join-Path $env:LOCALAPPDATA 'DX Media Player Backups'
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$backupPath = Join-Path $backupRoot ('DXMediaPlayer-build-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.zip')
# HEAD is the reproducible source snapshot. Refuse uncommitted source changes.
$pendingSource = git status --porcelain
if ($LASTEXITCODE -ne 0 -or $pendingSource) { throw 'Commit source changes before a reproducible build' }
git archive --format=zip --output=$backupPath HEAD
if ($LASTEXITCODE -ne 0) { throw 'Source backup failed; build not started' }
python -c "import PySide6, numpy, PyInstaller, pefile, PIL, faster_whisper, tokenizers, onnxruntime, av"
if ($LASTEXITCODE -ne 0) { throw 'Install requirements.txt first' }
if (-not $SkipApplication) { & "$PSScriptRoot\packaging\build.ps1" }
if ($SkipInstaller) { Write-Output 'Installer explicitly skipped'; exit 0 }
$compilerCandidates = @(
    $env:INNO_SETUP_COMPILER,
    (Join-Path $env:LOCALAPPDATA 'DX Media Player Build\tools\InnoSetup\ISCC.exe'),
    'C:\Program Files\Inno Setup 7\ISCC.exe',
    'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'
)
$compiler = $compilerCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $compiler) { throw 'Inno Setup compiler missing. Set INNO_SETUP_COMPILER to ISCC.exe.' }
$installerWork = Join-Path $env:LOCALAPPDATA ('DX Media Player Build\installer\'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $installerWork -Force | Out-Null
python packaging/validate_package.py 'build\DXMediaPlayer'
if ($LASTEXITCODE -ne 0) { throw 'Application package integrity failed; installer not built' }
$inputPackage = Join-Path $installerWork 'input\DXMediaPlayer'
New-Item -ItemType Directory -Path (Split-Path -Parent $inputPackage) -Force | Out-Null
Copy-Item -LiteralPath 'build\DXMediaPlayer' -Destination $inputPackage -Recurse
python packaging/validate_package.py $inputPackage
if ($LASTEXITCODE -ne 0) { throw 'Installer input integrity failed' }
New-Item -ItemType Directory -Path 'verification' -Force | Out-Null
& $compiler "/O$installerWork" "/DAppFilesDir=$inputPackage" 'packaging\installer.iss' 2>&1 | Tee-Object -FilePath 'verification\installer-build.log'
if ($LASTEXITCODE -ne 0) { throw 'Installer build failed' }
$candidate = Join-Path $installerWork 'DXMediaPlayer-Setup.exe'
if (-not (Test-Path -LiteralPath $candidate)) { throw 'Fresh installer missing' }
$expectedHash = (Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash
$stagingOutput = Join-Path $PSScriptRoot 'build\DXMediaPlayer-Setup.exe.pending'
Copy-Item -LiteralPath $candidate -Destination $stagingOutput -Force
if ((Get-FileHash -LiteralPath $stagingOutput -Algorithm SHA256).Hash -ne $expectedHash) { throw 'Installer copy hash mismatch; previous output preserved' }
Move-Item -LiteralPath $stagingOutput -Destination 'build\DXMediaPlayer-Setup.exe' -Force
if (-not (Test-Path -LiteralPath 'build\DXMediaPlayer-Setup.exe')) { throw 'Installer missing after build' }
if ((Get-FileHash -LiteralPath 'build\DXMediaPlayer-Setup.exe' -Algorithm SHA256).Hash -ne $expectedHash) { throw 'Published installer hash mismatch' }
"$($expectedHash.ToLowerInvariant())  DXMediaPlayer-Setup.exe" | Set-Content -Encoding ascii 'build\DXMediaPlayer-Setup.SHA256.txt'
python scripts/verify_setup_portability.py 'build\DXMediaPlayer-Setup.exe' 'verification\installer-portability.json'
if ($LASTEXITCODE -ne 0) { throw 'Standalone installer copy/integrity validation failed' }
@{
    source_commit = (git rev-parse HEAD)
    source_backup = $backupPath
    installer_sha256 = $expectedHash.ToLowerInvariant()
    embedded_payload = $true
    package_verified = $true
    native_installation = 'NOT_TESTED; separate Windows/UAC test required'
} | ConvertTo-Json | Set-Content -Encoding utf8 'verification\build-report.json'
Write-Output 'DX Media Player: build\DXMediaPlayer\DXMediaPlayer.exe and build\DXMediaPlayer-Setup.exe'
