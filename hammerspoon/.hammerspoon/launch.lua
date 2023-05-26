local M = {}

function M.toggleApp(appName, moveToCurrentSpace)
  local app = hs.appfinder.appFromName(appName)
  if not app:isRunning() then
    hs.application.launchOrFocus(appName)
  else
    -- print("Running")
    if app == hs.application.frontmostApplication() then
      -- print("hiding")
      app:hide()
    else
      if moveToCurrentSpace then
        local win = app:mainWindow()
        local focused_space_id = hs.spaces.focusedSpace()
        hs.spaces.moveWindowToSpace(win:id(), focused_space_id)
      end
      app:activate()
    end
  end
end


return M
