
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

local function tileHorizontally(fraction, idx)
    local win = hs.window.focusedWindow()
    if win == nil then
        return
    end
    local curFrame = win:frame()
    local screen = win:screen()
    if screen == nil then
        return
    end
    local max = screen:frame()
    if curFrame.w == 0 then
        return
    end

    -- hs.alert.show(tostring((max.w-curFrame.w)))
    curFrame.w = max.w * fraction
    curFrame.x = max.x + max.w * fraction * (idx - 1)

    -- hs.alert.show(tostring((max.h-curFrame.h)))
    curFrame.h = max.h
    curFrame.y = 0
    win:setFrame(curFrame)
end

local function centerWindow()
    local win = hs.window.focusedWindow()
    if win == nil then
        return
    end
    local curFrame = win:frame()
    local screen = win:screen()
    if screen == nil then
        return
    end
    local s = screen:frame()
    if curFrame.w == 0 then
        return
    end

    -- hs.alert.show(tostring((max.w-curFrame.w)))
    -- curFrame.w = max.w * fraction
    curFrame.x = s.x + s.w/2 - curFrame.w/2
    curFrame.y = s.y + s.h/2 - curFrame.h/2

    -- hs.alert.show(tostring((max.h-curFrame.h)))
    -- curFrame.h = max.h
    -- curFrame.y = 0
    win:setFrame(curFrame)
end

function windowNextScreen()
    local win = hs.window.focusedWindow()
    local currentScreen = win:screen()
    local allScreens = hs.screen.allScreens()
    currentScreenIndex = hs.fnutils.indexOf(allScreens, currentScreen)
    nextScreenIndex = currentScreenIndex + 1

    if allScreens[nextScreenIndex] then
        win:moveToScreen(allScreens[nextScreenIndex])
    else
        win:moveToScreen(allScreens[1])
    end
end

hs.hotkey.bind('alt', '=', function() increaseWidth(80) end)
hs.hotkey.bind('alt', '-', function() increaseWidth(-80) end)
hs.hotkey.bind(hyper, '=', function() increaseHeight(40) end)
hs.hotkey.bind(hyper, '-', function() increaseHeight(-40) end)

hs.hotkey.bind(hyper, 'n', function() windowNextScreen() end)
hs.hotkey.bind(hyper, 'j', function() windowNextScreen() end)

hs.hotkey.bind(hyper, 'h', function() tileHorizontally(0.5, 1) end)
hs.hotkey.bind(hyper, 'l', function() tileHorizontally(0.5, 2) end)
hs.hotkey.bind(hyper, 'return', function() tileHorizontally(1.0, 1) end)
hs.hotkey.bind(hyper, 'y', function() tileHorizontally(0.3333333, 1) end)
hs.hotkey.bind(hyper, 'u', function() tileHorizontally(0.6666666, 1) end)
hs.hotkey.bind(hyper, 'i', function() tileHorizontally(0.6666666, 1.5) end)
hs.hotkey.bind(hyper, 'o', function() tileHorizontally(0.3333333, 3) end)
hs.hotkey.bind('alt', 'c', function() centerWindow() end)

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
-- hs.hotkey.bind('alt', 'r', function() launch.toggleApp("KeeWeb", true) end)
hs.hotkey.bind('alt', 'r', function() launch.toggleApp("Bitwarden", true) end)

-- hs.hotkey.bind('alt', '1', function() spaces.switoToSpace(1) end)
-- hs.hotkey.bind('alt', '2', function() spaces.switoToSpace(2) end)
-- hs.hotkey.bind('alt', '3', function() spaces.switoToSpace(3) end)
-- hs.hotkey.bind('alt', '2', function() hs.spaces.gotoSpace(2) end)

-- reload
hs.hotkey.bind(hyper, 'r', function()
    hs.reload()
end)
hs.alert.show("Config reloaded")

