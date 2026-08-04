local M = {}

-- Unlike hs.window.visibleWindows(), this filter maintains its window list from
-- accessibility events instead of querying every application on every keypress.
local windowFilter = hs.window.filter.defaultCurrentSpace

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

local function focusDirection(direction)
  local currentWindow = hs.window.focusedWindow()
  if not currentWindow then return end

  local currentFrame = currentWindow:frame()
  local currentID = currentWindow:id()
  local rule = directions[direction]
  local nearestWindow = nil
  local nearestDistance = math.huge

  for _, candidateWindow in ipairs(windowFilter:getWindows()) do
    if candidateWindow:id() ~= currentID then
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

  if nearestWindow then nearestWindow:focus() end
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
