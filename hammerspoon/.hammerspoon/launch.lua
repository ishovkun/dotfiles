local M = {}

function onActiveSpace(win_id)
  local active_spaces = hs.spaces.activeSpaces()
  local win_spaces = hs.spaces.windowSpaces(win_id)
  for _,win_space in pairs(win_spaces) do
    for screen, screen_space in pairs(active_spaces) do
      if win_space == screen_space then
        return true
      end
    end
  end
  return false
end

function M.toggleApp(appName, moveToCurrentSpace)
  local app = hs.appfinder.appFromName(appName)
  if not app:isRunning() then
    hs.application.launchOrFocus(appName)
  else
    if app == hs.application.frontmostApplication() then
      app:hide()
    else
      if moveToCurrentSpace then
        local win = app:mainWindow()
        if not onActiveSpace(win:id()) then
          local focused_space_id = hs.spaces.focusedSpace()
          app:unhide()
          hs.spaces.moveWindowToSpace(win:id(), focused_space_id)
        end
      end
      app:unhide()
      app:activate()
      win:raise()
    end
  end
end


return M
