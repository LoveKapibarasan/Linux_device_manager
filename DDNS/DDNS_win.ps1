# C:\Scripts\wireguard-reconnect.ps1

$Domain = "home.yourdomain.com"
$TunnelName = "wg0"
$EnvFile = "C:\Scripts\.wg-endpoint"
$CheckInterval = 300  # 5分（秒）

while ($true) {
    Write-Host "$(Get-Date): Checking WireGuard endpoint..."

    # 前回のIPを取得
    $LastIP = ""
    if (Test-Path $EnvFile) {
        $LastIP = Get-Content $EnvFile -Raw
        $LastIP = $LastIP.Trim()
    }

    # 現在のIPを解決
    try {
        $CurrentIP = (Resolve-DnsName -Name $Domain -Type A -ErrorAction Stop).IPAddress | Select-Object -First 1
    } catch {
        Write-Host "$(Get-Date): ERROR - Cannot resolve $Domain"
        Start-Sleep -Seconds $CheckInterval
        continue
    }

    # IPが変わったかチェック
    if ($CurrentIP -eq $LastIP) {
        Write-Host "$(Get-Date): No change. Current IP: $CurrentIP"
    } else {
        Write-Host "$(Get-Date): IP changed from $LastIP to $CurrentIP"

        # IPを保存
        $CurrentIP | Out-File -FilePath $EnvFile -Encoding ASCII -NoNewline

        # WireGuard再接続
        $Service = Get-Service -Name "WireGuardTunnel`$$TunnelName" -ErrorAction SilentlyContinue
        if ($Service -and $Service.Status -eq 'Running') {
            Write-Host "$(Get-Date): Restarting WireGuard..."

            & "C:\Program Files\WireGuard\wireguard.exe" /uninstalltunnelservice $TunnelName
            Start-Sleep -Seconds 3
            & "C:\Program Files\WireGuard\wireguard.exe" /installtunnelservice "C:\Program Files\WireGuard\Data\Configurations\$TunnelName.conf"

            Write-Host "$(Get-Date): WireGuard restarted"
        }
    }

    Start-Sleep -Seconds $CheckInterval
}