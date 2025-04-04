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
  -- print("======================")
  -- print("app is", app)
  if not app:isRunning() then
    hs.application.launchOrFocus(appName)
    -- print("return")
    return
  end
  if app == hs.application.frontmostApplication() and app:mainWindow() ~= nil then
    -- print("frontmost, return")
    local win = app:mainWindow()
    -- print("main window: ", win)
    app:hide()
  else
    local win = app:mainWindow()
    if app:mainWindow() == nil then
      for idx, w in pairs(app:allWindows()) do
        print(idx, w, w:isStandard())
        if w:isStandard() then
          -- print("Unminimizing")
          print(idx, w)
          w:unminimize()
          win = w
          -- print("win inside", win)
        end
      end
    end
    -- print("win", win)
    if moveToCurrentSpace then
      if not onActiveSpace(win:id()) then
        local focused_space_id = hs.spaces.focusedSpace()
        app:unhide()
        hs.spaces.moveWindowToSpace(win:id(), focused_space_id)
      end
    end
    app:activate()
    win:raise()
  end
end


return M
