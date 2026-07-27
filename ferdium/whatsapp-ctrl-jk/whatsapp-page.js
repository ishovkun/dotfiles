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
      !event.ctrlKey ||
      event.altKey ||
      event.metaKey ||
      event.shiftKey ||
      (event.code !== 'KeyJ' && event.code !== 'KeyK')
    ) {
      return;
    }

    const chatList =
      document.querySelector('#pane-side') ||
      document.querySelector('[data-testid="chat-list"]');
    const selectedChat = chatList?.querySelector('[aria-selected="true"]');
    const selectedRow = selectedChat?.closest('[role="row"]');
    const chatRows = [
      ...(chatList?.querySelectorAll('[role="row"]') || []),
    ].filter(row =>
      row.querySelector(
        '[data-testid="cell-frame-container"], [aria-selected]',
      ),
    );
    const selectedIndex = chatRows.indexOf(selectedRow);

    emitLog('keydown', {
      code: event.code,
      isTrusted: event.isTrusted,
      rowCount: chatRows.length,
      selectedIndex,
    });

    if (!chatRows.length) {
      emitLog('no-target');
      return;
    }

    const offset = event.code === 'KeyJ' ? 1 : -1;
    const targetIndex = selectedIndex === -1
      ? (event.code === 'KeyJ' ? 0 : chatRows.length - 1)
      : (selectedIndex + offset + chatRows.length) % chatRows.length;
    const targetRow = chatRows[targetIndex];
    const candidates = [
      targetRow.querySelector('[aria-selected]'),
      targetRow.querySelector('[role="gridcell"]'),
      targetRow.querySelector('[data-testid="cell-frame-container"]'),
      targetRow,
    ].filter(Boolean);

    const getReactProps = element => {
      const propertyNames = Object.getOwnPropertyNames(element);
      const propsKey = propertyNames.find(name =>
        name.startsWith('__reactProps$'),
      );
      if (propsKey) {
        return element[propsKey];
      }

      const fiberKey = propertyNames.find(name =>
        name.startsWith('__reactFiber$'),
      );
      return fiberKey ? element[fiberKey]?.memoizedProps : null;
    };

    const actionable = candidates
      .map(element => ({ element, props: getReactProps(element) }))
      .map(candidate => ({
        ...candidate,
        handlerName:
          typeof candidate.props?.onMouseDown === 'function'
            ? 'onMouseDown'
            : typeof candidate.props?.onClick === 'function'
              ? 'onClick'
              : null,
      }))
      .find(({ handlerName }) => handlerName);

    if (!actionable) {
      emitLog('no-react-handler', {
        targetIndex,
        candidateCount: candidates.length,
      });
      return;
    }

    event.preventDefault();
    event.stopImmediatePropagation();

    const eventType =
      actionable.handlerName === 'onMouseDown' ? 'mousedown' : 'click';
    const bounds = actionable.element.getBoundingClientRect();
    const nativeEvent = new MouseEvent(eventType, {
      bubbles: true,
      cancelable: true,
      composed: true,
      view: window,
      button: 0,
      buttons: eventType === 'mousedown' ? 1 : 0,
      clientX: bounds.left + bounds.width / 2,
      clientY: bounds.top + bounds.height / 2,
    });

    actionable.props[actionable.handlerName]({
      nativeEvent,
      type: eventType,
      target: actionable.element,
      currentTarget: actionable.element,
      button: 0,
      buttons: eventType === 'mousedown' ? 1 : 0,
      clientX: nativeEvent.clientX,
      clientY: nativeEvent.clientY,
      preventDefault() {},
      stopPropagation() {},
      persist() {},
      isDefaultPrevented: () => false,
      isPropagationStopped: () => false,
    });
    emitLog('react-handler', {
      targetIndex,
      handlerName: actionable.handlerName,
      startupAnchor: selectedIndex === -1,
    });
  },
  true,
);
