[CmdletBinding()]
param(
    [switch]$Drafts,
    [ValidateRange(1, 65535)]
    [int]$Port = 4000
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $repoRoot
try {
    if (-not (Get-Command ruby -ErrorAction SilentlyContinue) -or -not (Get-Command bundle -ErrorAction SilentlyContinue)) {
        throw 'Ruby and Bundler are required. Run .\script\setup.ps1 first.'
    }

    & bundle check
    if ($LASTEXITCODE -ne 0) {
        throw 'Project gems are missing. Run .\script\setup.ps1 first.'
    }

    $jekyllArguments = @('serve', '--host', '127.0.0.1', '--port', "$Port")
    if ($Drafts) {
        $jekyllArguments += '--drafts'
        Write-Host 'Draft preview is enabled; draft posts will appear using their original dates.' -ForegroundColor Yellow
    }

    Write-Host "Starting the local site at http://127.0.0.1:$Port/ (Ctrl+C stops the server)." -ForegroundColor Cyan
    & bundle exec jekyll @jekyllArguments
    if ($LASTEXITCODE -ne 0) {
        throw 'The Jekyll preview server exited with an error.'
    }
}
finally {
    Pop-Location
}