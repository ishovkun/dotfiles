
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

hyper = {'alt', 'shift'}

-- require "launch"

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

local launch = require("launch")

hs.hotkey.bind('alt', 'e', function() launch.toggleApp("Ferdium", true) end)
hs.hotkey.bind('alt', 'd', function() launch.toggleApp("Forklift", false) end)
hs.hotkey.bind('alt', 'return', function() launch.toggleApp("Alacritty", true) end)
hs.hotkey.bind('alt', 't', function() launch.toggleApp("Terminal", true) end)

-- reload
hs.hotkey.bind(hyper, 'r', function()
    hs.reload()
end)
hs.alert.show("Config reloaded")
