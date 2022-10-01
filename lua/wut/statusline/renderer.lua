--[[
Copyright (c) 2022 Lucas Trevisan (lucastrvsn@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

---@module "wut.statusline.renderer"

local M = {}

---@param module string | table
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

---@param module string | table
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
        goto continue
      end

      result = result .. parse_module(module.render())
    end

    ::continue::
  end

  return result
end

return M
