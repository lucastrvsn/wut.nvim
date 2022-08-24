local ui = require "wut/ui"

local M = {
  value = 0,
}

return setmetatable(M, {
  __call = function(_, initial_value)
    M.value = initial_value or nil

    local set_value = ui.dispatch(function(new_value)
      M.value = new_value
    end)

    return M.value, set_value
  end,
})
