$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DEST = "C:\Program Files\regexdns"
$DNS_PORT=5354
$dns = "127.0.0.1"
$BASE_NAME="regexdns"
$svc="regexdns"


# nssm が見つからなければインストール
if (-not $nssm) {
    choco install nssm -y
    $nssm = (Get-Command nssm.exe).Source
}
$nssm = (Get-Command nssm.exe -ErrorAction SilentlyContinue).Source

# Stop & Remove existing service (ignore errors)
& $nssm stop $svc 2>$null
& $nssm remove $svc confirm 2>$null


if (Test-Path $DEST) {
    Remove-Item $DEST -Recurse -Force
}

$REAL_HOME = [Environment]::GetFolderPath("UserProfile")
# remove log
Remove-Item "$REAL_HOME\$BASE_NAME.log"

# mkdir
New-Item -ItemType Directory -Path $DEST | Out-Null
Push-Location $DEST

# copy dir
Copy-Item "$SCRIPT_DIR\*" $DEST -Recurse -Force

Set-Location $DEST
if (-not (Test-Path ".venv")) {
    python -m venv .venv
}
& .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
& .\.venv\Scripts\python.exe -m pip install --upgrade pip
Copy-Item "$SCRIPT_DIR/../white_list/_white-list.csv" "$DEST/white-list.csv"
pyinstaller --onefile --add-data "white-list.csv;." "$BASE_NAME.py"

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

# Auto start
& $nssm set $svc Start SERVICE_AUTO_START

# Start now
& $nssm start $svc

# Nssm Check
& $nssm dump $svc

Write-Host "Service registered."

Write-Information "Check available port."
netstat -ano | findstr :54

Write-Information "DNS seting is already protected."

# Check ports
netstat -ano | findstr :53

# Change DNS Server
$interfaces = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

foreach ($i in $interfaces) {
    Write-Information "Setting DNS for interface: $($i.Name)"
    netsh interface ip set dns name="$($i.Name)" static $dns
}

Pop-Location