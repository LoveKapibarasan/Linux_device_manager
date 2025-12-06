$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DEST = "C:\Program Files\shutdown-cui"
$BASE_NAME="shutdown-cui"
$svc = "shutdowncui"
$nssm = (Get-Command nssm.exe -ErrorAction SilentlyContinue).Source

# nssm が見つからなければインストール
if (-not $nssm) {
    choco install nssm -y
    $nssm = (Get-Command nssm.exe).Source
}

# kill before
taskkill /f /im "$BASE_NAME.exe"


# Stop & Remove existing service (ignore errors)
& $nssm stop $svc 2>$null
& $nssm remove $svc confirm 2>$null

if (Test-Path $DEST) {
    Remove-Item $DEST -Recurse -Force
}

$REAL_HOME = [Environment]::GetFolderPath("UserProfile")

# remove log
Remove-Item "$REAL_HOME\notify.log" -ErrorAction SilentlyContinue

# mkdir
New-Item -ItemType Directory -Path $DEST | Out-Null
Push-Location $DEST

# copy
Copy-Item "$SCRIPT_DIR\*" $DEST -Recurse -Force

Set-Location $DEST

if (Test-Path ".venv") {
    Remove-Item ".venv" -Recurse -Force
}
python -m venv .venv

& .\.venv\Scripts\Activate.ps1
& .\.venv\Scripts\pip.exe install -r requirements.txt
& .\.venv\Scripts\python.exe -m pip install --upgrade pip
# Compile
& .\.venv\Scripts\pyinstaller.exe shutdown-cui.spec

# create new service
Write-Host "Creating service..."

Write-Host "Using NSSM: $nssm"

# Install new service
& $nssm install $svc "$DEST\dist\$BASE_NAME.exe"

# Configure logging
$logDir="$DEST\logs"
New-Item -ItemType Directory -Path $logDir | Out-Null

& $nssm set $svc AppDirectory "$DEST"
& $nssm set $svc AppRotateFiles 1
& $nssm set $svc AppStdout "$logDir\$BASE_NAME.log"
& $nssm set $svc AppStderr "$logdir\$BASE_NAME.log"
& $nssm set $svc AppRotateFiles 0


# 4. Auto start
& $nssm set $svc Start SERVICE_AUTO_START

# 5. Start now
& $nssm start $svc

# Check
& $nssm dump $svc

Pop-Location