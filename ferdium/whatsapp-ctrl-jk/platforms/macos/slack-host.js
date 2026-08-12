(() => {
  const bridgeKey = '__dotfilesSlackAdaptiveDragRegions';
  const existing = window[bridgeKey];
  if (existing) {
    existing.bindAll();
    existing.render();
    return { installed: true, reused: true };
  }

  const style = document.createElement('style');
  style.id = 'dotfiles-slack-drag-region-style';
  style.textContent = `
    body:has(.services__webview.is-active[data-name="Slack"])
      .window-draggable {
      app-region: no-drag !important;
      -webkit-app-region: no-drag !important;
    }
  `;
  document.head.append(style);

  const layer = document.createElement('div');
  layer.id = 'dotfiles-slack-drag-region-layer';
  Object.assign(layer.style, {
    inset: '0',
    pointerEvents: 'none',
    position: 'fixed',
    zIndex: '10001',
  });
  document.body.append(layer);

  const layouts = new WeakMap();
  const boundWebviews = new WeakSet();

  const render = () => {
    layer.replaceChildren();

    const allWrappers = [...document.querySelectorAll('.services__webview')];
    const activeSlackWrappers = allWrappers.filter(wrapper => (
      wrapper.classList.contains('is-active') &&
      wrapper.dataset.name === 'Slack'
    ));
    for (const wrapper of activeSlackWrappers) {
      const webview = wrapper.querySelector('webview');
      const layout = webview && layouts.get(webview);
      if (!layout?.viewport?.width || !layout?.viewport?.height) {
        continue;
      }

      const webviewBounds = webview.getBoundingClientRect();
      const scaleX = webviewBounds.width / layout.viewport.width;
      const scaleY = webviewBounds.height / layout.viewport.height;

      const toolbar = layout.toolbar;
      if (!toolbar || toolbar.width <= 0 || toolbar.height <= 0) {
        continue;
      }

      const dragRegion = document.createElement('div');
      Object.assign(dragRegion.style, {
        left: `${webviewBounds.left + toolbar.x * scaleX}px`,
        pointerEvents: 'none',
        position: 'fixed',
        top: `${webviewBounds.top + toolbar.y * scaleY}px`,
        userSelect: 'none',
        width: `${toolbar.width * scaleX}px`,
        height: `${toolbar.height * scaleY}px`,
      });
      dragRegion.style.setProperty('app-region', 'drag', 'important');
      dragRegion.style.setProperty(
        '-webkit-app-region',
        'drag',
        'important',
      );
      layer.append(dragRegion);

      for (const region of layout.noDragRegions || []) {
        if (region.width <= 0 || region.height <= 0) {
          continue;
        }

        const noDragRegion = document.createElement('div');
        Object.assign(noDragRegion.style, {
          left: `${webviewBounds.left + region.x * scaleX}px`,
          pointerEvents: 'none',
          position: 'fixed',
          top: `${webviewBounds.top + region.y * scaleY}px`,
          width: `${region.width * scaleX}px`,
          height: `${region.height * scaleY}px`,
        });
        noDragRegion.style.setProperty('app-region', 'no-drag', 'important');
        noDragRegion.style.setProperty(
          '-webkit-app-region',
          'no-drag',
          'important',
        );
        layer.append(noDragRegion);
      }
    }
  };

  const bindWebview = webview => {
    if (boundWebviews.has(webview)) {
      return;
    }
    boundWebviews.add(webview);
    webview.addEventListener('ipc-message', event => {
      if (event.channel !== 'dotfiles-slack-drag-regions') {
        return;
      }
      layouts.set(webview, event.args[0]);
      render();
    });
  };

  const bindAll = () => {
    document.querySelectorAll('webview').forEach(bindWebview);
  };

  const observer = new MutationObserver(mutations => {
    if (
      mutations.every(
        mutation => mutation.target === layer || layer.contains(mutation.target),
      )
    ) {
      return;
    }
    bindAll();
    render();
  });
  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ['class', 'data-name'],
    childList: true,
    subtree: true,
  });
  window.addEventListener('resize', render);

  window[bridgeKey] = {
    bindAll,
    layer,
    layouts,
    observer,
    render,
  };
  bindAll();
  render();
  return { installed: true, reused: false };
})();
