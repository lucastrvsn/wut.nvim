local hooks = require "wut/ui/hooks"
local deep_equal = require("wut/ui/utils").deep_equal

return function(callback, deps)
  local _current_index = hooks.get_index()
  local _deps = hooks.get_value(_current_index)
  local _has_changed = not deep_equal(deps, _deps)

  if _has_changed or not _deps then
    hooks.set(_current_index, deps)
    callback()
  end

  hooks.next()
end
