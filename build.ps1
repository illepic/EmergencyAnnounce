# Builds dist\EmergencyAnnounce-<version>.zip for CurseForge.
# The zip holds one EmergencyAnnounce folder with only the files the game needs.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$name = 'EmergencyAnnounce'
$files = @("$name.toc", "$name.lua", 'LICENSE', 'README.md', 'CHANGELOG.md')

$version = (Select-String -Path (Join-Path $root "$name.toc") -Pattern '^## Version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
$zip = Join-Path $dist "$name-$version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
try {
    foreach ($f in $files) {
        # Forward slashes, so the zip unpacks correctly everywhere.
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, (Join-Path $root $f), "$name/$f") | Out-Null
    }
} finally {
    $archive.Dispose()
}
Write-Output "Built $zip"
