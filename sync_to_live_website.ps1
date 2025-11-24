param(
    [string]$SourcePath = "E:\code\Project\DocForge\website",
    [string]$TargetPath = "E:\code\Project\docforge-website"
)

Write-Host "=== DocForge website sync ===" -ForegroundColor Cyan
Write-Host "Source: $SourcePath" -ForegroundColor Yellow
Write-Host "Target: $TargetPath" -ForegroundColor Yellow

if (-not (Test-Path -LiteralPath $SourcePath)) {
    Write-Error "Source path does not exist: $SourcePath"
    exit 1
}

if (-not (Test-Path -LiteralPath $TargetPath)) {
    Write-Error "Target path does not exist: $TargetPath"
    exit 1
}

# Confirm before overwriting files
Write-Host "This will copy ALL files from:`n  $SourcePath`ninto:`n  $TargetPath`n(overwriting files with the same name)." -ForegroundColor Yellow
$answer = Read-Host "Continue? (Y/N)"
if ($answer -notin @('Y','y')) {
    Write-Host "Aborted by user." -ForegroundColor DarkYellow
    exit 0
}

# Perform recursive copy, overwriting existing files
Copy-Item -Path "$SourcePath\*" -Destination $TargetPath -Recurse -Force
Write-Host "File sync completed." -ForegroundColor Green

Write-Host ""
Write-Host "=== Git operations in target repo ===" -ForegroundColor Cyan
Set-Location -LiteralPath $TargetPath

Write-Host "`nCurrent git status:" -ForegroundColor Yellow
git status

$runGit = Read-Host "Run 'git add .', 'git commit', and 'git push' now? (Y/N)"
if ($runGit -in @('Y','y')) {
    $commitMsg = Read-Host "Commit message (default: Sync website from DocForge repo)"
    if (-not $commitMsg) {
        $commitMsg = "Sync website from DocForge repo"
    }

    git add .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "git add failed. You can run git commands manually below." -ForegroundColor Red
    }
    else {
        git commit -m "$commitMsg"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "git commit failed (maybe no changes to commit). You can run git commands manually below." -ForegroundColor Yellow
        }
        else {
            git push
            if ($LASTEXITCODE -ne 0) {
                Write-Host "git push failed. You can run git commands manually below." -ForegroundColor Red
            }
            else {
                Write-Host "git push completed successfully." -ForegroundColor Green
            }
        }
    }
}
else {
    Write-Host "Skipped git add/commit/push. You can run git commands manually below." -ForegroundColor Yellow
}

Write-Host "`nScript finished. You can continue using this PowerShell window to run more git commands if needed." -ForegroundColor Green
Read-Host "Press Enter to close this window"
