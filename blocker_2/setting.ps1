$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DEST = "C:\Program Files\shutdown-cui"

if (Test-Path $DEST) {
    Remove-Item $DEST -Recurse -Force
}
# mkdir
New-Item -ItemType Directory -Path $DEST | Out-Null

# copy
Copy-Item "$SCRIPT_DIR\*" $DEST -Recurse -Force

# register
sc.exe create shutdown-cui `
    binPath= "`"$DEST\.venv\bin\python.exe`" `"$DEST\shutdown_cui.py`"" `
    displayname= "shutdown-cui-service" `
    start= auto

sc.exe failure shutdown-cui reset= 86400 actions= restart/5000

