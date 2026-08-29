param(
    [Parameter(Mandatory=$true)][string]$ZipPath,
    [string]$Message = "Update resourcepack"
)

# deploy_resourcepack.ps1
# Copies a built resourcepack zip into the git clone, commits, pushes,
# then reports the SHA-1 that server.properties needs.

$ErrorActionPreference = "Stop"
$repo = "C:\Users\James Wallis\Downloads\Cobblemon Server Working Files\Cobblia-Resource-Pack-git"
$target = Join-Path $repo "Cobblia_Trainers_resourcepack.zip"

if (-not (Test-Path $ZipPath)) { Write-Error "Zip not found: $ZipPath"; exit 1 }

Write-Host "Copying $ZipPath -> repo..." -ForegroundColor Cyan
Copy-Item $ZipPath $target -Force

$hash = (Get-FileHash $target -Algorithm SHA1).Hash.ToLower()
$size = (Get-Item $target).Length

Set-Location $repo
git add Cobblia_Trainers_resourcepack.zip
$status = git status --porcelain
if (-not $status) {
    Write-Host "No changes to commit - pack is already identical." -ForegroundColor Yellow
} else {
    git commit -m $Message
    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    git push origin main
    if ($LASTEXITCODE -ne 0) { Write-Error "Push failed"; exit 1 }
}

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "size : $size bytes"
Write-Host "sha1 : $hash"
Write-Host ""
Write-Host "server.properties line:" -ForegroundColor Yellow
Write-Host "resource-pack-sha1=$hash"
Write-Host ""
Write-Host "Wait ~5 min for the CDN, then update server.properties and RESTART." -ForegroundColor Yellow
