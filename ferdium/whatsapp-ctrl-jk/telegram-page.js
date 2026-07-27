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

let navigationCursor;

const getPeerIdFromHash = () => {
  const [route, query = ''] = window.location.hash.split('?');
  const params = new URLSearchParams(query);
  const peerId = params.get('p') || route.slice(1);
  return peerId && !peerId.startsWith('/') && !peerId.startsWith('@')
    ? peerId
    : undefined;
};

const getOpenChatPeerId = () => {
  const activeChat = document.querySelector('.chat.tabs-tab.active');
  return (
    activeChat?.querySelector(
      '.input-message-input[data-peer-id]',
    )?.dataset.peerId ||
    activeChat?.querySelector(
      '.bubble[data-peer-id]',
    )?.dataset.peerId ||
    getPeerIdFromHash()
  );
};

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

    const visibleTopicContainer = [
      ...document.querySelectorAll('.topics-container.is-visible'),
    ].find(container => container.getClientRects().length > 0);
    const mainRows = [
      ...document.querySelectorAll('.chatlist-chat[data-peer-id]'),
    ].filter(
      row =>
        !row.closest('.topics-container') &&
        row.getClientRects().length > 0,
    );
    const openChatPeerId = getOpenChatPeerId();
    let navigationScope = visibleTopicContainer ? 'topic' : 'main';
    let selectedRow = (visibleTopicContainer || document).querySelector(
      '.chatlist-chat.active[data-peer-id]',
    );
    if (!selectedRow && visibleTopicContainer) {
      selectedRow =
        mainRows.find(
          row =>
            navigationCursor &&
            row.dataset.peerId === navigationCursor.peerId &&
            row.dataset.threadId === navigationCursor.threadId,
        ) ||
        mainRows.find(row => row.classList.contains('is-forum-open'));
      navigationScope = 'main-cursor';
    } else if (!selectedRow) {
      selectedRow = mainRows.find(
        row => row.dataset.peerId === openChatPeerId,
      );
      if (selectedRow) {
        navigationScope = 'main-open-chat';
      }
    }
    const activeList =
      selectedRow?.closest('.chatlist') ||
      mainRows[0]?.closest('.chatlist');
    const rows = [
      ...(activeList?.querySelectorAll(
        '.chatlist-chat[data-peer-id]',
      ) || []),
    ].filter(row => row.getClientRects().length > 0);
    const selectedIndex = rows.indexOf(selectedRow);
    emitLog('keydown', {
      code: event.code,
      isTrusted: event.isTrusted,
      rowCount: rows.length,
      selectedIndex,
      navigationScope,
      threadId: selectedRow?.dataset.threadId,
      cursorPeerId: navigationCursor?.peerId,
      openChatPeerId,
      hash: window.location.hash,
    });

    if (!rows.length) {
      emitLog('no-target');
      return;
    }

    event.preventDefault();
    event.stopImmediatePropagation();

    const offset = event.code === 'KeyJ' ? 1 : -1;
    const targetIndex = selectedIndex === -1
      ? (event.code === 'KeyJ' ? 0 : rows.length - 1)
      : (selectedIndex + offset + rows.length) % rows.length;
    const target = rows[targetIndex];
    navigationCursor = {
      peerId: target.dataset.peerId,
      threadId: target.dataset.threadId,
    };
    target.scrollIntoView({
      block: 'center',
      inline: 'nearest',
      behavior: 'auto',
    });
    const bounds = target.getBoundingClientRect();
    const mouseDown = new MouseEvent('mousedown', {
      bubbles: true,
      cancelable: true,
      composed: true,
      view: window,
      button: 0,
      buttons: 1,
      clientX: bounds.left + bounds.width / 2,
      clientY: bounds.top + bounds.height / 2,
    });
    const dispatchResult = target.dispatchEvent(mouseDown);
    const mouseUp = new MouseEvent('mouseup', {
      bubbles: true,
      cancelable: true,
      composed: true,
      view: window,
      button: 0,
      buttons: 0,
      clientX: bounds.left + bounds.width / 2,
      clientY: bounds.top + bounds.height / 2,
    });
    const releaseResult = target.dispatchEvent(mouseUp);
    emitLog('mousedown', {
      targetIndex,
      peerId: target.dataset.peerId,
      threadId: target.dataset.threadId,
      dispatchResult,
      releaseResult,
      defaultPrevented: mouseDown.defaultPrevented,
    });
  },
  true,
);
