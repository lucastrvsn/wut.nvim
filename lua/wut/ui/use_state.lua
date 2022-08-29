local dispatch = require("wut/ui").dispatch
local hooks = require "wut/ui/hooks"

return function(initial_value)
  local _index = hooks.get_index()

  hooks.set(_index, hooks.get_value(_index) or initial_value)

  local set_value = dispatch(function(new_value)
    if type(new_value) == "function" then
      hooks.set(_index, new_value(hooks.get_value(_index)))
    else
      hooks.set(_index, new_value)
    end
  end, true)

  return hooks.get_value(_index, true), set_value
end
