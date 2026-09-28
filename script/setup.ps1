[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $repoRoot
try {
    if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
        throw 'Ruby was not found. Install Ruby 3.4 x64 with DevKit from https://rubyinstaller.org/ and reopen PowerShell.'
    }

    $rubyVersionText = & ruby -e 'print RUBY_VERSION'
    if ($LASTEXITCODE -ne 0) {
        throw 'Ruby could not report its version.'
    }

    if ([version]$rubyVersionText -lt [version]'3.2') {
        throw "Ruby $rubyVersionText is too old. Install Ruby 3.4 x64 with DevKit."
    }

    $rubyPlatform = & ruby -e 'print RUBY_PLATFORM'
    if ($LASTEXITCODE -ne 0) {
        throw 'Ruby could not report its platform.'
    }

    if ($rubyPlatform -notmatch 'x64-mingw-ucrt') {
        throw "Ruby platform '$rubyPlatform' does not match the lockfile. Install the x64 UCRT RubyInstaller package."
    }

    if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
        Write-Host 'Bundler is missing; installing it for the current Ruby installation.'
        & gem install bundler
        if ($LASTEXITCODE -ne 0) {
            throw 'Bundler installation failed.'
        }
    }

    Write-Host "Using Ruby $rubyVersionText ($rubyPlatform). Installing project gems..."
    & bundle install
    if ($LASTEXITCODE -ne 0) {
        throw 'bundle install failed. Check the RubyInstaller DevKit setup and try again.'
    }

    Write-Host 'Building the site to verify the local Jekyll setup...'
    & bundle exec jekyll build
    if ($LASTEXITCODE -ne 0) {
        throw 'The Jekyll build failed. Review the error above before previewing.'
    }

    Write-Host 'Setup complete. Run .\script\preview.ps1 to start the local preview.' -ForegroundColor Green
}
finally {
    Pop-Location
}