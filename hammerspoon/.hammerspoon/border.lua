local M = {}

-- One canvas for the whole session, moved and resized on focus changes.
-- Creating a fresh full-window canvas per focus event leaked a hidden window
-- (and its window-sized drawing buffers, in Hammerspoon and WindowServer)
-- every time, even with canvas:delete(): hundreds of windows, GBs of memory.
local color = {red = 0x5E/255, green = 0x81/255, blue = 0xAC/255, alpha = 1.0}
local width = 1
local mouseHeld = false
local updateTimer = nil

local canvas = hs.canvas.new({x = 0, y = 0, w = 1, h = 1})
canvas:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = color,
    strokeWidth = width,
    frame = {x = width / 2, y = width / 2, w = 1, h = 1},
    roundedRectRadii = {xRadius = 16, yRadius = 16},
})
canvas:behavior({"canJoinAllSpaces"})
canvas:level(hs.canvas.windowLevels.floating)
M._canvas = canvas

-- hs.window.filter misses windowDestroyed for some apps (closing a Finder
-- window fires no filter event at all), which left the border on screen.
-- Watch the bordered window itself instead; only one such watcher exists.
local targetWatcher = nil
local targetId = nil

local function watchTarget(win)
    if win and win:id() == targetId then return end
    if targetWatcher then targetWatcher:stop(); targetWatcher = nil end
    targetId = win and win:id() or nil
    if not win then return end
    targetWatcher = win:newWatcher(function() M.scheduleUpdate() end)
    targetWatcher:start({
        hs.uielement.watcher.elementDestroyed,
        hs.uielement.watcher.windowMoved,
        hs.uielement.watcher.windowResized,
        hs.uielement.watcher.windowMinimized,
    })
end

local function hide()
    canvas:hide()
    watchTarget(nil)
end

function M.update()
    if mouseHeld then return hide() end
    local win = hs.window.focusedWindow()
    if win == nil or win:isFullScreen() then return hide() end
    -- Only frame real app windows. Finder can report a leftover Quick Look
    -- panel (subrole "Quick Look") as focused after its last window closes.
    if not win:isStandard() or not win:isVisible() then return hide() end
    -- Skip if the window's space isn't currently active on any screen
    -- (e.g. after SLSProcessAssignToSpace moved it to a hidden space).
    local win_spaces = hs.spaces.windowSpaces(win:id()) or {}
    local active_set = {}
    for _, sid in pairs(hs.spaces.activeSpaces() or {}) do active_set[sid] = true end
    local visible = false
    for _, sid in ipairs(win_spaces) do
        if active_set[sid] then visible = true; break end
    end
    if not visible then return hide() end
    local f = win:frame()
    canvas:frame({
        x = f.x - width,
        y = f.y - width,
        w = f.w + width * 2,
        h = f.h + width * 2,
    })
    canvas:elementAttribute(1, "frame", {x = width / 2, y = width / 2, w = f.w + width, h = f.h + width})
    canvas:show()
    watchTarget(win)
end

-- Focus changes generate both unfocused and focused events. Coalesce them and
-- redraw after the hotkey callback returns so border work cannot delay focus.
function M.scheduleUpdate()
    if updateTimer then updateTimer:stop() end
    updateTimer = hs.timer.doAfter(0.01, function()
        updateTimer = nil
        M.update()
    end)
end

-- Window lifecycle
M._filter = hs.window.filter.new()
M._filter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowUnfocused,
    hs.window.filter.windowMoved,
    hs.window.filter.windowDestroyed,
    hs.window.filter.windowMinimized,
    hs.window.filter.windowHidden,
    hs.window.filter.windowFullscreened,
    hs.window.filter.windowUnfullscreened,
    hs.window.filter.windowNotVisible,
}, M.scheduleUpdate)

-- window.filter misses some destructions when a whole app quits (cmd-Q),
-- so also refresh on app termination and when an app is deactivated (its last
-- window closed and focus moved to another app).
M._appWatcher = hs.application.watcher.new(function(_, eventType)
    if eventType == hs.application.watcher.terminated
        or eventType == hs.application.watcher.activated
        or eventType == hs.application.watcher.deactivated then
        M.scheduleUpdate()
    end
end)
M._appWatcher:start()

-- Hide border while the left mouse button is held. Re-enables itself if
-- macOS disables the tap (e.g. timeout from a slow callback).
M._mouseTap = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.leftMouseUp,
    hs.eventtap.event.types.tapDisabledByTimeout,
    hs.eventtap.event.types.tapDisabledByUserInput,
}, function(event)
    local t = event:getType()
    if t == hs.eventtap.event.types.leftMouseDown then
        mouseHeld = true
        hs.timer.doAfter(0, hide)
    elseif t == hs.eventtap.event.types.leftMouseUp then
        mouseHeld = false
        M.scheduleUpdate()
    elseif t == hs.eventtap.event.types.tapDisabledByTimeout
        or t == hs.eventtap.event.types.tapDisabledByUserInput then
        M._mouseTap:start()
    end
    return false
end)
M._mouseTap:start()

M.update()

return M
