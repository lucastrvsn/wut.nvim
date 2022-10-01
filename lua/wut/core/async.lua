local core = require "wut/core"

local M = {}

M.wrap = function(fn)
  local value = nil

  core.scheduler():spawn(function()
    value = core:scheduler():yield(fn())
  end)

  return value
end

M.await = function(...)
  return core.scheduler():yield(...)
end

return M
