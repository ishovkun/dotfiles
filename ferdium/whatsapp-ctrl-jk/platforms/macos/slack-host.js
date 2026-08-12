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

    const activeSlackWrappers = document.querySelectorAll(
      '.services__webview.is-active[data-name="Slack"]',
    );
    for (const wrapper of activeSlackWrappers) {
      const webview = wrapper.querySelector('webview');
      const layout = webview && layouts.get(webview);
      if (!layout?.viewport?.width || !layout?.viewport?.height) {
        continue;
      }

      const webviewBounds = webview.getBoundingClientRect();
      const scaleX = webviewBounds.width / layout.viewport.width;
      const scaleY = webviewBounds.height / layout.viewport.height;

      for (const region of layout.regions || []) {
        if (region.width <= 0 || region.height <= 0) {
          continue;
        }

        const dragRegion = document.createElement('div');
        const width = region.width * scaleX;
        Object.assign(dragRegion.style, {
          alignItems: 'center',
          background: 'rgba(43, 214, 255, 0.55)',
          border: '2px solid #00c8ff',
          boxSizing: 'border-box',
          color: '#07151f',
          display: 'flex',
          font: '700 10px/1 -apple-system, BlinkMacSystemFont, sans-serif',
          justifyContent: 'center',
          left: `${webviewBounds.left + region.x * scaleX}px`,
          letterSpacing: '0.08em',
          pointerEvents: 'none',
          position: 'fixed',
          top: `${webviewBounds.top + region.y * scaleY}px`,
          userSelect: 'none',
          width: `${width}px`,
          height: `${region.height * scaleY}px`,
        });
        dragRegion.style.setProperty('app-region', 'drag', 'important');
        dragRegion.style.setProperty(
          '-webkit-app-region',
          'drag',
          'important',
        );
        if (width >= 54) {
          dragRegion.textContent = 'DRAG';
        }
        layer.append(dragRegion);
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
      requestAnimationFrame(() => {
        webview.send('dotfiles-slack-drag-regions-applied', {
          receivedRegions: event.args[0]?.regions?.length || 0,
          renderedRegions: layer.children.length,
          computedRegions: [...layer.children].map(region => ({
            appRegion: getComputedStyle(region).getPropertyValue(
              '-webkit-app-region',
            ),
            bounds: region.getBoundingClientRect().toJSON(),
          })),
        });
      });
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
