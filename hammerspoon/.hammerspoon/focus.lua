local M = {}

function M.focusEast()
  local cur_window = hs.window.focusedWindow()
  local f_cur = cur_window:frame()

  local minDiff = 1e4
  local next_window = cur_window

  local windows = hs.window.visibleWindows()
  -- for _, window in pairs(windows) do
  --   if window ~= hs.window.desktop() then
  --     local f = window:frame()
  --     local diff = f.x - f_cur.x
  --     if diff > 0 and diff < minDiff then
  --       minDiff = diff
  --       next_window = window
  --     end
  --   end
  -- end
  for _, window in pairs(windows) do
    if window ~= hs.window.desktop() then
      local f = window:frame()
      if f.y < f_cur.y + f_cur.h and f.y + f.h > f_cur.y then
        local diff = f.x - f_cur.x
        if diff > 0 and diff < minDiff then
          minDiff = diff
          next_window = window
        end
      end
    end
  end

  next_window:focus()
end

function M.focusWest()
  local cur_window = hs.window.focusedWindow()
  local f_cur = cur_window:frame()

  local minDiff = 1e4
  local next_window = cur_window

  local windows = hs.window.visibleWindows()
  for _, window in pairs(windows) do
    if window ~= hs.window.desktop() then
      local f = window:frame()
      if f.y < f_cur.y + f_cur.h and f.y + f.h > f_cur.y then
        local diff = f_cur.x - f.x
        if diff > 0 and diff < minDiff then
          minDiff = diff
          next_window = window
        end
      end
    end
  end

  next_window:focus()
end

function M.focusSouth()
  local cur_window = hs.window.focusedWindow()
  local f_cur = cur_window:frame()

  local minDiff = 1e4
  local next_window = cur_window

  local windows = hs.window.visibleWindows()
  for _, window in pairs(windows) do
    if window ~= hs.window.desktop() then
      local f = window:frame()
      if f.x < f_cur.x + f_cur.w and f.x + f.w > f_cur.x then
        local diff = f.y - f_cur.y
        if diff > 0 and diff < minDiff then
          minDiff = diff
          next_window = window
        end
      end
    end
  end

  next_window:focus()
end

function M.focusNorth()
  local cur_window = hs.window.focusedWindow()
  local f_cur = cur_window:frame()

  local minDiff = 1e4
  local next_window = cur_window

  local windows = hs.window.visibleWindows()
  -- for _, window in pairs(windows) do
  --   if window ~= hs.window.desktop() then
  --     local f = window:frame()
  --     local diff = f_cur.y - f.y
  --     if diff > 0 and diff < minDiff then
  --       minDiff = diff
  --       next_window = window
  --     end
  --   end
  -- end

  for _, window in pairs(windows) do
    if window ~= hs.window.desktop() then
      local f = window:frame()
      if f.x < f_cur.x + f_cur.w and f.x + f.w > f_cur.x then
        local diff = f_cur.y - f.y
        if diff > 0 and diff < minDiff then
          minDiff = diff
          next_window = window
        end
      end
    end
  end

  next_window:focus()
end

return M
