const macosEmitLog = (event, details = {}) => {
  window.dispatchEvent(
    new CustomEvent('dotfiles-ctrl-jk-log', {
      detail: { event, details },
    }),
  );
};

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
