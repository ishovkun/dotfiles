const fs = require('fs');
const path = require('path');

module.exports = (_config, userscript) => {
  const service = path.basename(__dirname);
  const logRoot = process.platform === 'darwin'
    ? path.join(process.env.HOME, 'Library', 'Logs')
    : process.env.XDG_STATE_HOME ||
      path.join(process.env.HOME, '.local', 'state');
  const logFile = path.join(logRoot, 'Ferdium', 'ctrl-jk.log');

  const log = (event, details = {}) => {
    try {
      fs.mkdirSync(path.dirname(logFile), { recursive: true });
      fs.appendFileSync(
        logFile,
        `${new Date().toISOString()} ${service} ${event} ${JSON.stringify(details)}\n`,
      );
    } catch (error) {
      console.error('[dotfiles ctrl-jk] logging failed', error);
    }
  };

  log('preload-loaded', {
    href: window.location.href,
    readyState: document.readyState,
  });

  window.addEventListener('dotfiles-ctrl-jk-log', event => {
    log(event.detail.event, event.detail.details);
  });

  userscript.recipe.injectJSUnsafe(
    path.join(__dirname, 'ctrl-jk-page.js'),
  );

  const platformPage = path.join(
    __dirname,
    'ctrl-jk-platform-page.js',
  );
  if (fs.existsSync(platformPage)) {
    userscript.recipe.injectJSUnsafe(platformPage);
  }
};
