local default_theme = require "wut/theme/default"

local M = {}

M.get = function(key)
  assert(type(key) == "string")

  local value = default_theme[key]

  if value ~= nil then
    return value
  end

  vim.cmd(
    string.format([[echoerr "WutTheme: variable \"%s\" not found."]], key)
  )

  return nil
end

M.hl = function(key)
  return M.get(key).highlight
end

M.ui = function(key)
  return M.get(key).icon
end

return M
