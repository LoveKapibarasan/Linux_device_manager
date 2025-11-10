# https://adguard-dns.io/kb/general/dns-filtering-syntax/
# powershell -ExecutionPolicy Bypass -File ".\white_list\win_sanitize.ps1"

$inputFile = Join-Path $PSScriptRoot "_white-list.csv"
$outputFile = Join-Path $PSScriptRoot "output.txt"

# Read all lines, process, and write result
Get-Content $inputFile |
        Where-Object { $_ -notmatch '^#' } |  # remove all lines starting with #
        Where-Object { $_.Trim() -ne "" } |    # remove empty lines
        ForEach-Object {
            $_ -replace '\$', '' -replace '\s+', ''   # removes $, whitespace, and
        } |
        ForEach-Object {
            "@@/$_/`$important"                     # wrap with prefix/suffix
        } |
        Set-Content $outputFile

Add-Content $outputFile '/.*/$denyallow=ai|net'