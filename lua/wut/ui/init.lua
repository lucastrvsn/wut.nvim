local events = require "wut/events"
local EventTypes = require "wut/events/types"

local M = {
  dispatchers = {},
}

M.dispatch = function(fn)
  return function()
    fn()

    events.notify(EventTypes.UIWindowUpdate)
    vim.pretty_print "oi"
  end
end

return M
