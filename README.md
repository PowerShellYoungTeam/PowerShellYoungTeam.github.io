# PowerShellYoungTeam

A personal portfolio and notes site built with Jekyll and Minima, hosted on GitHub Pages.

## Local preview on Windows

Install Ruby once using [RubyInstaller for Windows](https://rubyinstaller.org/). Choose the Ruby 3.4 x64 UCRT **with DevKit** package, then complete the MSYS2/DevKit setup if the installer prompts you. The repository lockfile targets `x64-mingw-ucrt`.

Open PowerShell in the repository and run:

```powershell
.\script\setup.ps1
```

The setup script checks Ruby and Bundler, installs the locked gems, and runs a Jekyll build as a smoke test. Start the local server with:

```powershell
.\script\preview.ps1
```

Open <http://127.0.0.1:4000/> in a browser. Keep the terminal open while previewing and press `Ctrl+C` to stop the server. Changes to site files are rebuilt locally; `_site` is generated output and should not be committed.

If PowerShell blocks local scripts, allow the script for the current process only:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\script\setup.ps1
```

Work-in-progress posts are kept in the tracked `_drafts/` folder. They are excluded from normal builds and GitHub Pages deployment. To preview them locally, run:

```powershell
.\script\preview.ps1 -Drafts
```

If another local preview is already using port 4000, choose a different port:

```powershell
.\script\preview.ps1 -Drafts -Port 4001
```

Equivalent manual commands:

```powershell
bundle install
bundle exec jekyll build
bundle exec jekyll serve
```

## Maintaining the site

- Project names, descriptions, categories, tags, repository links, and featured selection live in `_data/projects.yml`.
- GitHub and Bluesky links live under `social` in `_config.yml`.
- Homepage and About content are in `index.html` and `about.md`; published posts belong in `_posts/`, and works in progress belong in `_drafts/`.
- Sass theme overrides are in `_sass/minima/`; `assets/css/style.scss` is the stylesheet entry point.

## Deploying with GitHub Pages

In the repository's **Settings > Pages**, select **GitHub Actions** as the build and deployment source. The workflow in `.github/workflows/pages.yml` builds and deploys on pushes to `main`; it can also be started manually from the Actions tab. GitHub Pages builds from the source files, so local preview output and dependency folders do not need to be committed.
