local M = {}

local hackmac_python = "/Users/ishovkun/code/playground/hackmac/.venv/bin/python"
local hackmac_script = "/Users/ishovkun/code/playground/hackmac/hackmac.py"

function M.getSpaceID(space_index)
  local all_spaces = hs.spaces.allSpaces()
  ispace = 1
  for screen_uuid, spaces in pairs(all_spaces) do
    for _, space_id in ipairs(spaces) do
      if ispace == space_index then
        return space_id
      end
      ispace = ispace + 1
    end
  end
  return -1
end

function M.getSpaceIDInScreen(screen_id, space_index)
  spaces = hs.spaces.spacesForScreen(screen_id)
  for idx, space_id in pairs(spaces) do
    if idx == space_index then
      return space_id
    end
  end
  return -1
end

function M.moveCurrentWindowToSpace(space_index)
  local win = hs.window.focusedWindow()

  local screen = hs.screen.mainScreen()
  local space_id = M.getSpaceIDInScreen(screen, space_index)

  -- this gets screens in variable order
  -- local space_id = M.getSpaceID(space_index)

  if space_id < 0 then
    hs.alert.show("Index " .. space_index .. " is too larse")
  else
    hs.spaces.moveWindowToSpace(win:id(), space_id)
  end
end

--- Move all windows of the focused app's process to a space.
--- Shells out to hackmac.py which calls SLSProcessAssignToSpace.
function M.moveCurrentAppToSpace(space_index)
  local win = hs.window.focusedWindow()
  if not win then
    hs.alert.show("No focused window")
    return
  end

  local screen = hs.screen.mainScreen()
  local space_id = M.getSpaceIDInScreen(screen, space_index)
  if space_id < 0 then
    hs.alert.show("Index " .. space_index .. " is too large")
    return
  end

  local app_name = win:application():name()
  hs.task.new(hackmac_python, function(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
      hs.alert.show("Move failed: " .. (stdErr or ""))
    end
  end, {hackmac_script, "move-app", app_name, tostring(space_id)}):start()
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
