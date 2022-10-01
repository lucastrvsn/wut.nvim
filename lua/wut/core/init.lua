local Scheduler = require "wut/core/scheduler"

local M = {
  _scheduler = Scheduler:new(),
}

M.init = function()
  -- local timer = vim.loop.new_timer()
  --
  -- timer:start(
  --   0,
  --   1000,
  --   vim.schedule_wrap(function()
  --     M._scheduler:tick()
  --     M._scheduler:dump()
  --   end)
  -- )

  M._scheduler:init()
end

M.scheduler = function()
  if not M._scheduler then
    error(debug.traceback "WutCoreScheduler was not initialized.")
  end

  return M._scheduler
end

return M
