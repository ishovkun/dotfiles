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

  if (service === 'slack' && process.platform === 'darwin') {
    const { ipcRenderer } = require('electron');
    const hostScriptFile = path.join(__dirname, 'ctrl-jk-host.js');
    let hostBridgeReady = false;
    let latestDragLayout;

    const sendDragLayout = layout => {
      try {
        ipcRenderer.sendToHost(
          'dotfiles-slack-drag-regions',
          layout,
        );
      } catch (error) {
        log('adaptive-drag-regions-send-failed', {
          message: error.message,
          stack: error.stack,
        });
      }
    };

    window.addEventListener('dotfiles-slack-drag-regions', event => {
      latestDragLayout = event.detail;
      if (hostBridgeReady) {
        sendDragLayout(latestDragLayout);
      }
    });

    ipcRenderer.on(
      'dotfiles-slack-drag-regions-applied',
      (_event, details) => log('adaptive-drag-regions-applied', details),
    );

    if (fs.existsSync(hostScriptFile)) {
      try {
        const remoteModule = path.join(
          process.resourcesPath,
          'app.asar',
          'node_modules',
          '@electron',
          'remote',
        );
        const remote = require(remoteModule);
        const browserWindow = remote.getCurrentWindow();
        const hostScript = fs.readFileSync(hostScriptFile, 'utf8');
        browserWindow.webContents.executeJavaScript(hostScript).then(result => {
          hostBridgeReady = true;
          log('adaptive-drag-host-bridge-installed', result);
          if (latestDragLayout) {
            sendDragLayout(latestDragLayout);
          }
        }).catch(error => {
          log('adaptive-drag-host-bridge-failed', {
            message: error.message,
            stack: error.stack,
          });
        });
      } catch (error) {
        log('adaptive-drag-host-bridge-failed', {
          message: error.message,
          stack: error.stack,
        });
      }
    }
  }

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
