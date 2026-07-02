param(
    [string]$CoreUrl = "https://raw.githubusercontent.com/mohavise/mohavise-adblock-core/main/core-domains.txt",
    [string]$DomainOutputFile = "..\pihole-adlist.txt"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptRoot

if (Test-Path -LiteralPath $CoreUrl) {
    $coreLines = Get-Content -LiteralPath $CoreUrl
} else {
    $content = Invoke-WebRequest -Uri $CoreUrl -UseBasicParsing
    $coreLines = $content.Content -split "`r?`n"
}

$final = $coreLines |
    ForEach-Object { $_.Trim().ToLowerInvariant() } |
    Where-Object { $_ -ne "" -and !$_.StartsWith("#") } |
    Sort-Object -Unique

$updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
$domainLines = [System.Collections.Generic.List[string]]::new()
[void]$domainLines.Add("# managed-by=mohavise-pihole-adlist")
[void]$domainLines.Add("# project=mohavise-pihole-adlist")
[void]$domainLines.Add("# do-not-edit-manually")
[void]$domainLines.Add("# generated-at=$updated")
$final | ForEach-Object { [void]$domainLines.Add($_) }

Set-Content -LiteralPath $DomainOutputFile -Value $domainLines -Encoding ASCII

Write-Host "Generated $DomainOutputFile with $($final.Count) blocked domains."
