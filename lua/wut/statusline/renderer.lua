local M = {}

local render_to_string = function(module)
  local highlight = nil

  if type(module.highlight) == "string" then
    highlight = module.highlight
  elseif type(module.style) == "table" then
    highlight = require("wut/highlight").create(module.style)
  end

  if highlight ~= nil then
    return "%#" .. highlight .. "#" .. module.content .. "%0*"
  end

  return module.content .. "%0*"
end

-- param module string|table
local parse_module = function(module)
  if type(module) == "table" then
    if type(module.items) == "table" then
      local result = module.content or ""

      for _, v in ipairs(module.items) do
        result = result .. render_to_string(v)
      end

      return result
    end

    return render_to_string(module)
  end

  return module
end

M.render = function(modules)
  local result = ""

  for _, module in ipairs(modules) do
    if type(module) == "table" then
      if type(module.condition) == "function" and not module.condition() then
        goto end_loop
      end

      result = result .. parse_module(module.render())
    end

    ::end_loop::
  end

  return result
end

return M
