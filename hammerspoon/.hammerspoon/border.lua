local M = {}

local canvas = nil
local color = {red = 0x5E/255, green = 0x81/255, blue = 0xAC/255, alpha = 1.0}
local width = 1
local mouseHeld = false

function M.update()
    if canvas then
        canvas:delete()
        canvas = nil
    end
    if mouseHeld then return end
    local win = hs.window.focusedWindow()
    if win == nil then return end
    if win:isFullScreen() then return end
    -- Skip if the window's space isn't currently active on any screen
    -- (e.g. after SLSProcessAssignToSpace moved it to a hidden space).
    local win_spaces = hs.spaces.windowSpaces(win:id()) or {}
    local active_set = {}
    for _, sid in pairs(hs.spaces.activeSpaces() or {}) do active_set[sid] = true end
    local visible = false
    for _, sid in ipairs(win_spaces) do
        if active_set[sid] then visible = true; break end
    end
    if not visible then return end
    local f = win:frame()
    canvas = hs.canvas.new({
        x = f.x - width,
        y = f.y - width,
        w = f.w + width * 2,
        h = f.h + width * 2,
    })
    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = color,
        strokeWidth = width,
        frame = {
            x = width / 2,
            y = width / 2,
            w = f.w + width,
            h = f.h + width,
        },
        roundedRectRadii = {xRadius = 16, yRadius = 16},
    })
    canvas:behavior({"canJoinAllSpaces"})
    canvas:level(hs.canvas.windowLevels.floating)
    canvas:show()
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
}, M.update)

-- window.filter misses some destructions when a whole app quits (cmd-Q),
-- so also refresh on app termination.
M._appWatcher = hs.application.watcher.new(function(_, eventType)
    if eventType == hs.application.watcher.terminated then
        hs.timer.doAfter(0, M.update)
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
        hs.timer.doAfter(0, function()
            if canvas then
                canvas:delete()
                canvas = nil
            end
        end)
    elseif t == hs.eventtap.event.types.leftMouseUp then
        mouseHeld = false
        hs.timer.doAfter(0, M.update)
    elseif t == hs.eventtap.event.types.tapDisabledByTimeout
        or t == hs.eventtap.event.types.tapDisabledByUserInput then
        M._mouseTap:start()
    end
    return false
end)
M._mouseTap:start()

M.update()

return M
