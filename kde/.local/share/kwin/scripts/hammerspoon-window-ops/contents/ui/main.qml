import QtQuick
import org.kde.kwin

Item {
    id: root

    readonly property int resizeStep: 150
    readonly property int minimumWidth: 240
    readonly property int minimumHeight: 180

    function activeResizableWindow() {
        const window = Workspace.activeWindow;
        if (!window || window.specialWindow || !window.resizeable) {
            return null;
        }
        return window;
    }

    function restoreWindow(window) {
        if (window.fullScreen) {
            window.fullScreen = false;
        }
        if (window.tile) {
            window.tile = null;
        }
        window.setMaximize(false, false);
    }

    function setGeometry(window, x, y, width, height) {
        restoreWindow(window);
        window.frameGeometry = Qt.rect(
            Math.round(x),
            Math.round(y),
            Math.round(width),
            Math.round(height)
        );
    }

    function placeFraction(xFraction, yFraction, widthFraction, heightFraction) {
        const window = activeResizableWindow();
        if (!window) {
            return;
        }

        const area = Workspace.clientArea(KWin.MaximizeArea, window);
        setGeometry(
            window,
            area.x + area.width * xFraction,
            area.y + area.height * yFraction,
            area.width * widthFraction,
            area.height * heightFraction
        );
    }

    function resizeWidth(delta) {
        const window = activeResizableWindow();
        if (!window) {
            return;
        }

        const area = Workspace.clientArea(KWin.MaximizeArea, window);
        const current = window.frameGeometry;
        const width = Math.max(
            minimumWidth,
            Math.min(area.width, current.width + delta)
        );
        const x = Math.max(
            area.x,
            Math.min(
                area.x + area.width - width,
                current.x - (width - current.width) / 2
            )
        );

        setGeometry(window, x, current.y, width, current.height);
    }

    function resizeHeight(delta) {
        const window = activeResizableWindow();
        if (!window) {
            return;
        }

        const area = Workspace.clientArea(KWin.MaximizeArea, window);
        const current = window.frameGeometry;
        const height = Math.max(
            minimumHeight,
            Math.min(area.height, current.height + delta)
        );
        const y = Math.max(
            area.y,
            Math.min(
                area.y + area.height - height,
                current.y - (height - current.height) / 2
            )
        );

        setGeometry(window, current.x, y, current.width, height);
    }

    function centerWindow() {
        const window = activeResizableWindow();
        if (!window) {
            return;
        }

        const area = Workspace.clientArea(KWin.MaximizeArea, window);
        const current = window.frameGeometry;
        const width = Math.min(current.width, area.width);
        const height = Math.min(current.height, area.height);
        setGeometry(
            window,
            area.x + (area.width - width) / 2,
            area.y + (area.height - height) / 2,
            width,
            height
        );
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Grow Width"
        text: "Grow the active window horizontally"
        sequence: "Meta+="
        onActivated: root.resizeWidth(root.resizeStep)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Shrink Width"
        text: "Shrink the active window horizontally"
        sequence: "Meta+-"
        onActivated: root.resizeWidth(-root.resizeStep)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Grow Height"
        text: "Grow the active window vertically"
        sequence: "Meta++"
        onActivated: root.resizeHeight(root.resizeStep)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Shrink Height"
        text: "Shrink the active window vertically"
        sequence: "Meta+_"
        onActivated: root.resizeHeight(-root.resizeStep)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Center Window"
        text: "Center the active window"
        sequence: "Meta+C"
        onActivated: root.centerWindow()
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Left Half"
        text: "Tile the active window to the left half"
        sequence: "Meta+Shift+H"
        onActivated: root.placeFraction(0, 0, 0.5, 1)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Bottom Half"
        text: "Tile the active window to the bottom half"
        sequence: "Meta+Shift+J"
        onActivated: root.placeFraction(0, 0.5, 1, 0.5)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Top Half"
        text: "Tile the active window to the top half"
        sequence: "Meta+Shift+K"
        onActivated: root.placeFraction(0, 0, 1, 0.5)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Right Half"
        text: "Tile the active window to the right half"
        sequence: "Meta+Shift+L"
        onActivated: root.placeFraction(0.5, 0, 0.5, 1)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Left Third"
        text: "Tile the active window to the left third"
        sequence: "Meta+Shift+Y"
        onActivated: root.placeFraction(0, 0, 1 / 3, 1)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Left Two Thirds"
        text: "Tile the active window to the left two thirds"
        sequence: "Meta+Shift+U"
        onActivated: root.placeFraction(0, 0, 2 / 3, 1)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Right Two Thirds"
        text: "Tile the active window to the right two thirds"
        sequence: "Meta+Shift+I"
        onActivated: root.placeFraction(1 / 3, 0, 2 / 3, 1)
    }

    ShortcutHandler {
        name: "Hammerspoon Window Ops: Right Third"
        text: "Tile the active window to the right third"
        sequence: "Meta+Shift+O"
        onActivated: root.placeFraction(2 / 3, 0, 1 / 3, 1)
    }
}
