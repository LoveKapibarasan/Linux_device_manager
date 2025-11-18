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


# 1. Stop & Remove existing service (ignore errors)
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

if (-not (Test-Path ".venv")) {
    python -m venv .venv
}
& .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
& .\.venv\Scripts\python.exe -m pip install --upgrade pip
pyinstaller --onefile --add-data "config.json;." shutdown-cui.py

# create new service
Write-Host "Creating service..."



Write-Host "Using NSSM: $nssm"

# 2. Install new service
& $nssm install $svc "$DEST\dist\$BASE_NAME.exe"


# 3. Configure logging
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


<#
# 1. !! no - !!
# 2. need .exe(p2exe)
# 3. need some API to be implemented

Start-Sleep -Seconds 2
sc.exe stop shutdowncui 2>$null
Start-Sleep -Seconds 2
sc.exe delete shutdowncui 2>$null
Start-Sleep -Seconds 2

if (-not (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue)) {
    Write-Host "Installing p2exe..."
    Install-Module -Name ps2exe -Scope CurrentUser -Force -Confirm:$false
}
Invoke-ps2exe -inputFile "$DEST\start_win.ps1" -outputFile "$DEST\start_win.exe" -noConsole

sc.exe create shutdowncui "binPath=$DEST\win_start.exe" "DisplayName= $BASE_NAME-service" "start=auto"

sc.exe failure $BASE_NAME reset= 86400 actions= restart/5000

# check
sc.exe qc shutdowncui

# Start now
Start-Service shutdowncui

# Log
Get-Service shutdowncui
#>

Pop-Location

# NTP
# w32tm /config /update /manualpeerlist:"time.windows.com,0x1" /syncfromflags:manual
# w32tm /resync


