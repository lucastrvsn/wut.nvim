local M = {}

M.remove_key = function(t, k)
  t[k] = nil
end

return M
