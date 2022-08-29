local M = {}

M.throttle = function(callback, ms)
  local last_time = 0

  return function(...)
    local current_time = last_time + ms

    if not last_time or vim.loop.now() > current_time then
      callback(...)

      last_time = vim.loop.now()
    end
  end
end

M.is_function = function(fn)
  if type(fn) == "table" then
    local _metatable = getmetatable(fn)

    return _metatable ~= nil and type(_metatable.__call) == "function"
  end

  return type(fn) == "function"
end

return M
