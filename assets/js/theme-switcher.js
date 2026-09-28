(function () {
  var themeButtons = document.querySelectorAll('[data-theme-choice]');
  var supportedThemes = ['light', 'dark', 'cyberpunk'];

  function setTheme(theme, savePreference) {
    if (!supportedThemes.includes(theme)) {
      return;
    }

    document.documentElement.dataset.theme = theme;
    themeButtons.forEach(function (button) {
      button.setAttribute('aria-pressed', String(button.dataset.themeChoice === theme));
    });

    if (savePreference) {
      try {
        localStorage.setItem('portfolio-theme', theme);
      } catch (error) {
        // The current page still changes theme when storage is unavailable.
      }
    }
  }

  setTheme(document.documentElement.dataset.theme || 'dark', false);

  themeButtons.forEach(function (button) {
    button.addEventListener('click', function () {
      setTheme(button.dataset.themeChoice, true);
    });
  });
})();