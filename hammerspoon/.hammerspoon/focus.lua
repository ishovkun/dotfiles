local M = {}

local focusLogPath = os.getenv("HOME")
  .. "/Library/Logs/Hammerspoon/directional-focus.log"
local focusCorrectionTimer

local function logFocus(message)
  local logDirectory = focusLogPath:match("^(.*)/[^/]+$")
  hs.fs.mkdir(logDirectory)
  local file = io.open(focusLogPath, "a")
  if not file then return end
  file:write(os.date("!%Y-%m-%dT%H:%M:%SZ "), message, "\n")
  file:close()
end

-- Unlike hs.window.visibleWindows(), this filter maintains its window list from
-- accessibility events instead of querying every application on every keypress.
local windowFilter = hs.window.filter.defaultCurrentSpace

local function shouldIgnoreWindow(window)
  local app = window:application()
  local title = window:title() or ""
  return app
    and app:name() == "Microsoft Teams"
    and title:match("^Meeting compact view%s*|") ~= nil
end

local directions = {
  east = {
    overlaps = function(candidate, current)
      return candidate.y < current.y + current.h
        and candidate.y + candidate.h > current.y
    end,
    distance = function(candidate, current)
      return candidate.x - current.x
    end,
  },
  west = {
    overlaps = function(candidate, current)
      return candidate.y < current.y + current.h
        and candidate.y + candidate.h > current.y
    end,
    distance = function(candidate, current)
      return current.x - candidate.x
    end,
  },
  south = {
    overlaps = function(candidate, current)
      return candidate.x < current.x + current.w
        and candidate.x + candidate.w > current.x
    end,
    distance = function(candidate, current)
      return candidate.y - current.y
    end,
  },
  north = {
    overlaps = function(candidate, current)
      return candidate.x < current.x + current.w
        and candidate.x + candidate.w > current.x
    end,
    distance = function(candidate, current)
      return current.y - candidate.y
    end,
  },
}

-- hs.window:focus() calls becomeMain() before activating the application.
-- Some multi-window apps restore their last key window during that activation,
-- replacing the specific window selected above. Activate first, then raise and
-- focus the exact AX window; repeat once after the activation settles.
local function focusExact(window, direction, sourceID)
  local targetID = window:id()
  local app = window:application()

  logFocus(string.format(
    "direction=%s source=%s target=%s app=%s title=%q",
    direction,
    tostring(sourceID),
    tostring(targetID),
    app and app:name() or "?",
    window:title() or ""
  ))

  if app then app:activate(false) end
  window:raise()
  window:becomeMain()

  if focusCorrectionTimer then focusCorrectionTimer:stop() end
  focusCorrectionTimer = hs.timer.doAfter(0.08, function()
    local focused = hs.window.focusedWindow()
    local correctionAttempted = false
    if not focused or focused:id() ~= targetID then
      correctionAttempted = true
      local target = hs.window.get(targetID)
      if target then
        target:raise()
        target:becomeMain()
      end
    end

    focused = hs.window.focusedWindow()
    logFocus(string.format(
      "direction=%s expected=%s focused=%s corrected=%s",
      direction,
      tostring(targetID),
      tostring(focused and focused:id()),
      tostring(correctionAttempted)
    ))
    focusCorrectionTimer = nil
  end)
end

local function focusDirection(direction)
  local currentWindow = hs.window.focusedWindow()
  if not currentWindow then return end

  local currentFrame = currentWindow:frame()
  local currentID = currentWindow:id()
  local rule = directions[direction]
  local nearestWindow = nil
  local nearestDistance = math.huge

  for _, candidateWindow in ipairs(windowFilter:getWindows()) do
    if candidateWindow:id() ~= currentID
        and not shouldIgnoreWindow(candidateWindow) then
      local candidateFrame = candidateWindow:frame()
      if rule.overlaps(candidateFrame, currentFrame) then
        local distance = rule.distance(candidateFrame, currentFrame)
        if distance > 0 and distance < nearestDistance then
          nearestDistance = distance
          nearestWindow = candidateWindow
        end
      end
    end
  end

  if nearestWindow then
    focusExact(nearestWindow, direction, currentID)
  end
end

function M.focusEast()
  focusDirection("east")
end

function M.focusWest()
  focusDirection("west")
end

function M.focusSouth()
  focusDirection("south")
end

function M.focusNorth()
  focusDirection("north")
end

return M
