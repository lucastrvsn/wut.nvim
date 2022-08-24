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

return M
