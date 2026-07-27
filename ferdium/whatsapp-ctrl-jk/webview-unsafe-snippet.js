// BEGIN dotfiles: whatsapp-ctrl-jk
// Navigate WhatsApp chats with Ctrl+J/K from Ferdium's page context.
document.addEventListener(
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
      row.querySelector('[data-testid="cell-frame-container"], [aria-selected]'),
    );
    const selectedIndex = chatRows.indexOf(selectedRow);

    if (selectedIndex === -1 || chatRows.length < 2) {
      return;
    }

    const offset = event.code === 'KeyJ' ? 1 : -1;
    const targetIndex =
      (selectedIndex + offset + chatRows.length) % chatRows.length;
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
  },
  true,
);
// END dotfiles: whatsapp-ctrl-jk
