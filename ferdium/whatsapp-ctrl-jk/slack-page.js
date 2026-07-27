const emitLog = (event, details = {}) => {
  window.dispatchEvent(
    new CustomEvent('dotfiles-ctrl-jk-log', {
      detail: { event, details },
    }),
  );
};

emitLog('page-loaded', {
  href: window.location.href,
  readyState: document.readyState,
});

window.addEventListener(
  'keydown',
  event => {
    if (
      !event.isTrusted ||
      !event.ctrlKey ||
      event.altKey ||
      event.metaKey ||
      event.shiftKey ||
      (event.code !== 'KeyJ' && event.code !== 'KeyK')
    ) {
      return;
    }

    const remap = {
      key: event.code === 'KeyJ' ? 'ArrowDown' : 'ArrowUp',
      keyCode: event.code === 'KeyJ' ? 40 : 38,
    };
    const originalGetModifierState =
      event.getModifierState.bind(event);

    try {
      Object.defineProperties(event, {
        key: { configurable: true, value: remap.key },
        code: { configurable: true, value: remap.key },
        keyCode: { configurable: true, value: remap.keyCode },
        which: { configurable: true, value: remap.keyCode },
        charCode: { configurable: true, value: 0 },
        ctrlKey: { configurable: true, value: false },
        altKey: { configurable: true, value: true },
        metaKey: { configurable: true, value: false },
        getModifierState: {
          configurable: true,
          value: modifier => {
            if (modifier === 'Alt' || modifier === 'AltGraph') {
              return true;
            }
            if (modifier === 'Control') {
              return false;
            }
            if (modifier === 'Meta' || modifier === 'OS') {
              return false;
            }
            return originalGetModifierState(modifier);
          },
        },
      });
    } catch (error) {
      emitLog('transform-error', {
        name: error.name,
        message: error.message,
      });
      return;
    }

    emitLog('transform', {
      action: 'chat-navigation',
      key: event.key,
      code: event.code,
      keyCode: event.keyCode,
      ctrlKey: event.ctrlKey,
      altKey: event.altKey,
      isTrusted: event.isTrusted,
      href: window.location.href,
    });
  },
  true,
);
