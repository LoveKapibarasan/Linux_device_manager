
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$configDir = Join-Path $SCRIPT_DIR ".config"

$files = @(".bashrc", ".profile", ".shellprofile", ".shellrc", ".bashprofile")

# 実際にログインしているユーザーのホームディレクトリを取得
# 管理者権限で実行されている場合でも元のユーザーを取得
$originalUser = if (Test-Path env:USERNAME) {
    $env:USERNAME
} else {
    [Environment]::UserName
}

# 管理者として実行されている場合、explorer.exeのプロセスから実際のユーザーを取得
if ($env:USERNAME -eq "Administrator") {
    try {
        $explorerProcess = Get-WmiObject Win32_Process -Filter "name = 'explorer.exe'" | Select-Object -First 1
        if ($explorerProcess) {
            $owner = $explorerProcess.GetOwner()
            $originalUser = $owner.User
        }
    } catch {
        Write-Warning "Could not detect original user, using current user"
    }
}

$targetDir = "C:\Users\$originalUser"

foreach ($file in $files) {
    $sourceFile = Join-Path $configDir $file
    $targetLink = Join-Path $targetDir $file
    
    if (-not (Test-Path $sourceFile)) {
        Write-Warning "No sourceFile: $sourceFile"
        continue
    }
    
    if (Test-Path $targetLink) {
        Remove-Item $targetLink -Force
        Write-Host "Delete existing Link: $targetLink"
    }
    
    # シンボリックリンクを作成
    New-Item -ItemType SymbolicLink -Path $targetLink -Target $sourceFile
    Write-Host "Link created: $file -> $targetLink"
}

