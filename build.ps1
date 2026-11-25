# Builds dist\EmergencyAnnounce-<version>.zip for GitHub and CurseForge.
# The zip holds one EmergencyAnnounce folder with only the files the game needs.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$name = 'EmergencyAnnounce'
$include = @("$name.toc", '*.lua', 'LICENSE', 'README.md', 'CHANGELOG.md', 'Locales', 'Libs')

$version = (Select-String -Path (Join-Path $root "$name.toc") -Pattern '^## Version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
$zip = Join-Path $dist "$name-$version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }

$files = foreach ($pattern in $include) {
    $path = Join-Path $root $pattern
    if (Test-Path $path -PathType Container) { Get-ChildItem $path -Recurse -File }
    else { Get-ChildItem $path -File }
}

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
try {
    foreach ($f in $files) {
        # Forward slashes, so the zip unpacks correctly everywhere.
        $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $f.FullName, "$name/$rel") | Out-Null
    }
} finally {
    $archive.Dispose()
}
Write-Output "Built $zip ($(@($files).Count) files)"
