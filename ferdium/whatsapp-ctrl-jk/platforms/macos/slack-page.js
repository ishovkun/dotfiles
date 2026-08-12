const macosEmitLog = (event, details = {}) => {
  window.dispatchEvent(
    new CustomEvent('dotfiles-ctrl-jk-log', {
      detail: { event, details },
    }),
  );
};

const macosInstallAdaptiveDragRegionReporter = () => {
  const marker = 'data-dotfiles-slack-adaptive-drag-region-reporter';
  if (document.documentElement.hasAttribute(marker)) {
    return;
  }
  document.documentElement.setAttribute(marker, '');

  const toolbarSelector = [
    '[data-qa="top-nav"]',
    '.p-ia4_top_nav[role="toolbar"]',
  ].join(',');
  const interactiveSelector = [
    'a',
    'button',
    'input',
    'select',
    'textarea',
    '[contenteditable="true"]',
    '[role="button"]',
    '[role="combobox"]',
    '[role="link"]',
    '[role="menuitem"]',
    '[role="textbox"]',
    '[tabindex]:not([tabindex="-1"])',
    '.p-ia4_top_nav__native_ui_spacer',
  ].join(',');

  let lastPayload;
  let reportTimer;
  let observedToolbar;
  let toolbarResizeObserver;
  let toolbarMutationObserver;

  const report = () => {
    const toolbar = document.querySelector(toolbarSelector);
    if (!toolbar) {
      return;
    }

    if (toolbar !== observedToolbar) {
      observedToolbar = toolbar;
      toolbarResizeObserver?.disconnect();
      toolbarMutationObserver?.disconnect();
      toolbarResizeObserver = new ResizeObserver(() => scheduleReport());
      toolbarResizeObserver.observe(toolbar);
      toolbarMutationObserver = new MutationObserver(() => scheduleReport());
      toolbarMutationObserver.observe(toolbar, {
        attributes: true,
        childList: true,
        subtree: true,
        attributeFilter: [
          'aria-hidden',
          'class',
          'disabled',
          'style',
          'tabindex',
        ],
      });
    }

    const toolbarBounds = toolbar.getBoundingClientRect();
    if (toolbarBounds.width <= 0 || toolbarBounds.height <= 0) {
      return;
    }

    const padding = 4;
    const noDragBounds = [...toolbar.querySelectorAll(interactiveSelector)]
      .filter(element => {
        const bounds = element.getBoundingClientRect();
        const style = getComputedStyle(element);
        return (
          bounds.width > 0 &&
          bounds.height > 0 &&
          bounds.bottom > toolbarBounds.top &&
          bounds.top < toolbarBounds.bottom &&
          style.display !== 'none' &&
          style.visibility !== 'hidden' &&
          style.pointerEvents !== 'none'
        );
      })
      .map(element => {
        const bounds = element.getBoundingClientRect();
        return {
          left: Math.max(toolbarBounds.left, bounds.left - padding),
          top: Math.max(toolbarBounds.top, bounds.top - padding),
          right: Math.min(toolbarBounds.right, bounds.right + padding),
          bottom: Math.min(toolbarBounds.bottom, bounds.bottom + padding),
        };
      })
      .sort((left, right) => (
        (right.right - right.left) * (right.bottom - right.top) -
        (left.right - left.left) * (left.bottom - left.top)
      ))
      .reduce((outermost, bounds) => {
        const contained = outermost.some(candidate => (
          candidate.left <= bounds.left &&
          candidate.top <= bounds.top &&
          candidate.right >= bounds.right &&
          candidate.bottom >= bounds.bottom
        ));
        if (!contained) {
          outermost.push(bounds);
        }
        return outermost;
      }, []);

    const payload = {
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight,
      },
      toolbar: {
        x: Math.round(toolbarBounds.left),
        y: Math.round(toolbarBounds.top),
        width: Math.round(toolbarBounds.width),
        height: Math.round(toolbarBounds.height),
      },
      noDragRegions: noDragBounds.map(bounds => ({
        x: Math.round(bounds.left),
        y: Math.round(bounds.top),
        width: Math.round(bounds.right - bounds.left),
        height: Math.round(bounds.bottom - bounds.top),
      })),
    };
    const serialized = JSON.stringify(payload);
    if (serialized === lastPayload) {
      return;
    }
    lastPayload = serialized;
    window.dispatchEvent(
      new CustomEvent('dotfiles-slack-drag-regions', { detail: payload }),
    );
  };

  const scheduleReport = () => {
    clearTimeout(reportTimer);
    reportTimer = setTimeout(report, 50);
  };

  window.addEventListener('resize', scheduleReport, true);
  scheduleReport();
  macosEmitLog('adaptive-drag-region-reporter-installed');
};

macosInstallAdaptiveDragRegionReporter();

const macosLastFocused = {};

const macosIsVisible = element =>
  element &&
  element.getClientRects().length > 0 &&
  getComputedStyle(element).visibility !== 'hidden';

const macosLargestVisible = selector =>
  [...document.querySelectorAll(selector)]
    .filter(macosIsVisible)
    .sort((left, right) => {
      const leftBounds = left.getBoundingClientRect();
      const rightBounds = right.getBoundingClientRect();
      return (
        rightBounds.width * rightBounds.height -
        leftBounds.width * leftBounds.height
      );
    })[0];

const macosSearchSelector = [
  '[data-qa*="search" i]',
  '[aria-label*="search" i]',
  '[placeholder*="search" i]',
  '[title*="search" i]',
  '[role="search"]',
  'input[type="search"]',
].join(',');

const macosRoundBounds = bounds => ({
  x: Math.round(bounds.x),
  y: Math.round(bounds.y),
  width: Math.round(bounds.width),
  height: Math.round(bounds.height),
  right: Math.round(bounds.right),
  bottom: Math.round(bounds.bottom),
});

const macosDescribeElement = element => {
  if (!(element instanceof Element)) {
    return undefined;
  }

  const style = getComputedStyle(element);
  const className = typeof element.className === 'string'
    ? element.className.trim().split(/\s+/).slice(0, 5).join(' ')
    : undefined;
  const searchLabel = [
    element.getAttribute('aria-label'),
    element.getAttribute('placeholder'),
    element.getAttribute('title'),
  ].some(value => value?.toLowerCase().includes('search'));

  return {
    tag: element.tagName,
    id: element.id || undefined,
    className: className || undefined,
    role: element.getAttribute('role') || undefined,
    dataQa: element.getAttribute('data-qa') || undefined,
    searchLabel,
    bounds: macosRoundBounds(element.getBoundingClientRect()),
    pointerEvents: style.pointerEvents,
    visibility: style.visibility,
    display: style.display,
    opacity: style.opacity,
    position: style.position,
    zIndex: style.zIndex,
  };
};

const macosSearchCandidates = () =>
  [...document.querySelectorAll(macosSearchSelector)]
    .filter(element => {
      const bounds = element.getBoundingClientRect();
      return (
        bounds.width > 0 &&
        bounds.height > 0 &&
        bounds.right > 0 &&
        bounds.bottom > 0 &&
        bounds.left < window.innerWidth &&
        bounds.top < window.innerHeight
      );
    })
    .slice(0, 12);

const macosLogSearchLayout = event => {
  macosEmitLog(event, {
    href: window.location.href,
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight,
      devicePixelRatio: window.devicePixelRatio,
    },
    active: macosDescribeElement(document.activeElement),
    candidates: macosSearchCandidates().map(macosDescribeElement),
  });
};

let macosSearchLayoutTimer;
const macosScheduleSearchLayout = event => {
  clearTimeout(macosSearchLayoutTimer);
  macosSearchLayoutTimer = setTimeout(
    () => macosLogSearchLayout(event),
    250,
  );
};

macosScheduleSearchLayout('search-layout-loaded');
window.addEventListener(
  'resize',
  () => macosScheduleSearchLayout('search-layout-resized'),
  true,
);

const macosNearBounds = (x, y, bounds, margin = 40) =>
  x >= bounds.left - margin &&
  x <= bounds.right + margin &&
  y >= bounds.top - margin &&
  y <= bounds.bottom + margin;

const macosLogSearchPointer = event => {
  if (!event.isTrusted) {
    return;
  }

  const candidates = macosSearchCandidates();
  const nearCandidate = candidates.some(element =>
    macosNearBounds(
      event.clientX,
      event.clientY,
      element.getBoundingClientRect(),
    ),
  );
  const inTopBar = event.clientY <= Math.min(160, window.innerHeight / 5);
  const pathHasSearch = event.composedPath().some(
    element => element instanceof Element && element.matches(macosSearchSelector),
  );

  if (!nearCandidate && !inTopBar && !pathHasSearch) {
    return;
  }

  macosEmitLog('search-pointer', {
    type: event.type,
    button: event.button,
    defaultPrevented: event.defaultPrevented,
    point: {
      x: Math.round(event.clientX),
      y: Math.round(event.clientY),
    },
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight,
      devicePixelRatio: window.devicePixelRatio,
    },
    target: macosDescribeElement(event.target),
    hitStack: document
      .elementsFromPoint(event.clientX, event.clientY)
      .slice(0, 8)
      .map(macosDescribeElement),
    candidates: candidates.map(macosDescribeElement),
  });

  setTimeout(() => {
    macosEmitLog('search-pointer-result', {
      sourceType: event.type,
      active: macosDescribeElement(document.activeElement),
      visibleDialogs: [...document.querySelectorAll('[role="dialog"]')]
        .filter(macosIsVisible)
        .length,
    });
  }, 100);
};

window.addEventListener('pointerdown', macosLogSearchPointer, true);
window.addEventListener('click', macosLogSearchPointer, true);

const macosGetPanes = () => {
  const sidebar = macosLargestVisible('.p-view_contents--sidebar');
  const primary = macosLargestVisible('.p-view_contents--primary');
  const primaryBounds = primary?.getBoundingClientRect();
  const rightCandidates = [
    ...document.querySelectorAll(
      '.p-view_contents--secondary, .p-view_contents--split',
    ),
  ].filter(element => {
    if (!macosIsVisible(element)) {
      return false;
    }
    const bounds = element.getBoundingClientRect();
    return (
      !primaryBounds ||
      bounds.left >= primaryBounds.left + primaryBounds.width / 2
    );
  });
  const right = rightCandidates.sort((left, candidate) => {
    const leftBounds = left.getBoundingClientRect();
    const candidateBounds = candidate.getBoundingClientRect();
    return (
      candidateBounds.left - leftBounds.left ||
      candidateBounds.width * candidateBounds.height -
        leftBounds.width * leftBounds.height
    );
  })[0];

  return [
    { key: 'sidebar', element: sidebar },
    { key: 'primary', element: primary },
    { key: 'right', element: right },
  ].filter(pane => pane.element);
};

const macosGetPaneForElement = element => {
  if (!element?.closest) {
    return undefined;
  }
  if (
    element.closest(
      '.p-view_contents--secondary, .p-view_contents--split',
    )
  ) {
    return 'right';
  }
  if (element.closest('.p-view_contents--primary')) {
    return 'primary';
  }
  if (element.closest('.p-view_contents--sidebar')) {
    return 'sidebar';
  }
};

document.addEventListener(
  'focusin',
  event => {
    const pane = macosGetPaneForElement(event.target);
    if (pane) {
      macosLastFocused[pane] = event.target;
    }
  },
  true,
);

const macosFindFocusTarget = pane => {
  const remembered = macosLastFocused[pane.key];
  if (
    remembered?.isConnected &&
    pane.element.contains(remembered) &&
    macosIsVisible(remembered)
  ) {
    return remembered;
  }

  const selectors = pane.key === 'sidebar'
    ? [
        '.p-channel_sidebar__channel--selected',
        '[aria-selected="true"]',
        '[aria-current="page"]',
        '[tabindex="0"]',
        '[role="listitem"]',
        'button',
        'a[href]',
      ]
    : [
        '[data-qa="message_input"] [contenteditable="true"]',
        '[data-qa="message_input"]',
        '[contenteditable="true"][role="textbox"]',
        '[role="textbox"]',
        '[tabindex="0"]',
        'button',
        'a[href]',
      ];

  for (const selector of selectors) {
    const target = [...pane.element.querySelectorAll(selector)].find(
      macosIsVisible,
    );
    if (target) {
      return target;
    }
  }
  return pane.element;
};

const macosMovePaneFocus = (event, direction) => {
  const panes = macosGetPanes();
  if (!panes.length) {
    macosEmitLog('pane-no-target');
    return;
  }

  const currentPane = macosGetPaneForElement(document.activeElement);
  const currentIndex = panes.findIndex(
    pane => pane.key === currentPane,
  );
  const targetIndex = currentIndex === -1
    ? (direction > 0 ? 0 : panes.length - 1)
    : (currentIndex + direction + panes.length) % panes.length;
  const targetPane = panes[targetIndex];
  const target = macosFindFocusTarget(targetPane);

  event.preventDefault();
  event.stopImmediatePropagation();

  if (!target.matches(
    'a[href], button, input, textarea, select, [tabindex], [contenteditable="true"]',
  )) {
    target.tabIndex = -1;
  }
  target.focus({ preventScroll: true });
  macosEmitLog('pane-focus', {
    from: currentPane,
    to: targetPane.key,
    paneCount: panes.length,
    targetTag: target.tagName,
    targetClass: target.className,
    targetQa: target.getAttribute('data-qa'),
  });
};

window.addEventListener(
  'keydown',
  event => {
    if (
      !event.isTrusted ||
      event.ctrlKey ||
      event.altKey ||
      event.metaKey ||
      event.shiftKey ||
      (event.code !== 'F16' && event.code !== 'F17')
    ) {
      return;
    }

    macosMovePaneFocus(event, event.code === 'F16' ? -1 : 1);
  },
  true,
);
