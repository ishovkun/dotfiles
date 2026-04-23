local activeNotification = nil
local notificationTimer = nil

local M = {}

function M.show(message, duration)
    duration = duration or 1.5
    if activeNotification then
        activeNotification:delete()
        activeNotification = nil
    end
    if notificationTimer then
        notificationTimer:stop()
        notificationTimer = nil
    end

    local screen = hs.screen.mainScreen():frame()
    local padding = 12
    local font = ".AppleSystemUIFont"
    local fontSize = 14
    local textSize = hs.drawing.getTextDrawingSize(message, {font = font, size = fontSize})
    local w = textSize.w + padding * 2
    local h = textSize.h + padding * 2
    local x = screen.x + screen.w - w - 16
    local y = screen.y + 16

    local c = hs.canvas.new({x = x, y = y, w = w, h = h})
    c:appendElements(
        {type = "rectangle", roundedRectRadii = {xRadius = 10, yRadius = 10},
         fillColor = {white = 0.15, alpha = 0.85}, strokeColor = {white = 0, alpha = 0}},
        {type = "text", text = message, textColor = {white = 1, alpha = 1},
         textFont = font, textSize = fontSize, textAlignment = "center",
         frame = {x = "0", y = tostring(padding / h), w = "1", h = tostring(textSize.h / h)}}
    )
    c:level(hs.canvas.windowLevels.overlay)
    c:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    c:alpha(0):show()

    -- fade in
    local fadeSteps = 10
    for i = 1, fadeSteps do
        hs.timer.doAfter(i * 0.01, function() if c then c:alpha(i / fadeSteps) end end)
    end

    notificationTimer = hs.timer.doAfter(duration, function()
        -- fade out
        for i = 1, fadeSteps do
            hs.timer.doAfter(i * 0.03, function()
                if c then c:alpha(1 - i / fadeSteps) end
            end)
        end
        hs.timer.doAfter(fadeSteps * 0.03 + 0.05, function()
            if c then c:delete() end
            if activeNotification == c then activeNotification = nil end
        end)
    end)
    activeNotification = c
end

return M
