local M = {}

local hackmac = require("hackmac_hs")
local border = require("border")

-- Screens sorted left-to-right, then top-to-bottom by frame origin, so
-- global space indices are deterministic across reloads and reconnects.
local function orderedScreens()
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    local fa, fb = a:frame(), b:frame()
    if fa.x ~= fb.x then return fa.x < fb.x end
    return fa.y < fb.y
  end)
  return screens
end

function M.getSpaceID(space_index)
  local idx = 1
  for _, screen in ipairs(orderedScreens()) do
    for _, space_id in ipairs(hs.spaces.spacesForScreen(screen:id())) do
      if idx == space_index then return space_id end
      idx = idx + 1
    end
  end
  return -1
end

function M.moveCurrentWindowToSpace(space_index)
  local win = hs.window.focusedWindow()
  local space_id = M.getSpaceID(space_index)
  if space_id < 0 then
    hs.alert.show("Index " .. space_index .. " is too large")
  else
    hs.spaces.moveWindowToSpace(win:id(), space_id)
  end
end

function M.moveProcessToSpaceID(pid, space_id)
  local rc = hackmac.moveProcessToSpace(pid, space_id)
  if rc ~= 0 then
    hs.alert.show("Move failed: " .. rc)
    return false
  end
  return true
end

function M.moveCurrentAppToSpace(space_index)
  local win = hs.window.focusedWindow()
  if not win then
    hs.alert.show("No focused window")
    return
  end

  local space_id = M.getSpaceID(space_index)
  if space_id < 0 then
    hs.alert.show("Index " .. space_index .. " is too large")
    return
  end

  local rc = hackmac.moveProcessToSpace(win:pid(), space_id)
  if rc ~= 0 then
    hs.alert.show("Move failed: " .. rc)
    return
  end
  border.update()
end

function getIndexFromValue(tbl, value)
  for index, val in ipairs(tbl) do
      if val == value then
          return index
      end
  end
  return nil  -- return nil if the value is not found
end

function M.switoToSpace(space_id)
  local screen = hs.screen.mainScreen()
  local spacesInScreen = hs.spaces.spacesForScreen(currentScreen)
  hs.spaces.gotoSpace(spacesInScreen[space_id])
end

return M
