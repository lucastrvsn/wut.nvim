local Scheduler = require "wut/core/scheduler"

local M = {
  scheduler = Scheduler:new(),
}

M.init = function()
  local last_time = vim.loop.now()
  local timer = vim.loop.new_timer()

  timer:start(0, 200, function()
    local time_now = vim.loop.now()
    local time_ellapsed = time_now - last_time

    M.scheduler:tick(time_ellapsed)
    M.scheduler:dump()

    last_time = time_now
  end)
end

return M
