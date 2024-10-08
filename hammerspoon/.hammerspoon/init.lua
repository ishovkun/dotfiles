
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

hyper = {'alt', 'shift'}

function increaseWidth(delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - delta / 2
  f.w = f.w + delta
  win:setFrame(f)
end
function increaseHeight(delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y - delta / 2
  f.h = f.h + delta
  win:setFrame(f)
end
function moveHorizontally(delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + delta
  win:setFrame(f)
end
function moveVertically(delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y + delta
  win:setFrame(f)
end

-- local winops = require("winops")
hs.hotkey.bind(hyper, 'l', function() increaseWidth(80) end)
hs.hotkey.bind(hyper, 'h', function() increaseWidth(-80) end)
hs.hotkey.bind(hyper, 'k', function() increaseHeight(80) end)
hs.hotkey.bind(hyper, 'j', function() increaseHeight(-80) end)

hs.hotkey.bind({"alt","control","shift"}, 'l', function() moveHorizontally(40) end)
hs.hotkey.bind({"alt","control","shift"}, 'h', function() moveHorizontally(-40) end)
hs.hotkey.bind({"alt","control","shift"}, 'k', function() moveVertically(40) end)
hs.hotkey.bind({"alt","control","shift"}, 'j', function() moveVertically(-40) end)

local spaces = require("spaces")

hs.hotkey.bind({"alt", "shift"}, "1", function() spaces.moveCurrentWindowToSpace(1) end)
hs.hotkey.bind({"alt", "shift"}, "2", function() spaces.moveCurrentWindowToSpace(2) end)
hs.hotkey.bind({"alt", "shift"}, "3", function() spaces.moveCurrentWindowToSpace(3) end)
hs.hotkey.bind({"alt", "shift"}, "4", function() spaces.moveCurrentWindowToSpace(4) end)
hs.hotkey.bind({"alt", "shift"}, "5", function() spaces.moveCurrentWindowToSpace(5) end)
hs.hotkey.bind({"alt", "shift"}, "6", function() spaces.moveCurrentWindowToSpace(6) end)
hs.hotkey.bind({"alt", "shift"}, "7", function() spaces.moveCurrentWindowToSpace(7) end)
hs.hotkey.bind({"alt", "shift"}, "8", function() spaces.moveCurrentWindowToSpace(8) end)
hs.hotkey.bind({"alt", "shift"}, "9", function() spaces.moveCurrentWindowToSpace(9) end)
hs.hotkey.bind({"alt", "shift"}, "0", function() spaces.moveCurrentWindowToSpace(10) end)

local focus = require("focus")
hs.hotkey.bind('alt', 'l', function() focus.focusEast() end)
hs.hotkey.bind('alt', 'h', function() focus.focusWest() end)
hs.hotkey.bind('alt', 'j', function() focus.focusSouth() end)
hs.hotkey.bind('alt', 'k', function() focus.focusNorth() end)
-- hs.hotkey.bind('alt', 'l', function() hs.window:focusWindowEast() end)
-- hs.hotkey.bind('alt', 'h', function() hs.window:focusWindowWest() end)
-- hs.hotkey.bind('alt', 'j', function() hs.window:focusWindowSouth() end)
-- hs.hotkey.bind('alt', 'k', function() hs.window:focusWindowNorth() end)

local launch = require("launch")

-- second argument meand whether to bring the app to the current workspace
hs.hotkey.bind('alt', 'e', function() launch.toggleApp("Ferdium", true) end)
hs.hotkey.bind('alt', 'd', function() launch.toggleApp("Forklift", true) end)
hs.hotkey.bind('alt', 'return', function() launch.toggleApp("Alacritty", true) end)
hs.hotkey.bind('alt', 't', function() launch.toggleApp("Terminal", true) end)
hs.hotkey.bind('alt', 'r', function() launch.toggleApp("KeeWeb", true) end)

-- reload
hs.hotkey.bind(hyper, 'r', function()
    hs.reload()
end)
hs.alert.show("Config reloaded")
