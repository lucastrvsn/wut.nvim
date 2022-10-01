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

---@module "wut.highlight"

local color = require "wut/color"

local M = {
  _prefix = "@wut",
  _cache = {},
}

local scope_highlight = function(name)
  return string.format("%s.%s", M._prefix, name)
end

local colors_to_neovim_api = function(colors)
  local result = {}

  for k, v in pairs(colors) do
    if type(v) == "table" and v._type == "Color" then
      result[k] = color.to_hex(v)
    elseif type(v) == "string" then
      result[k] = v
    end
  end

  return result
end

M.get = function(name)
  local value = M._cache[name]

  if value ~= nil then
    return value.name
  end

  return nil
end

M.create = function(opts)
  assert(type(opts.name) == "string")

  if M.get(opts.name) ~= nil then
    vim.cmd(
      string.format(
        [[WutHighlight: highlight name "%s" already exists]],
        opts.name
      )
    )
  end

  local highlight_name = scope_highlight(opts.name)
  local highlight_ns = opts.namespace or 0
  local highlight_style = opts.style or {}

  if type(opts.link) == "string" then
    vim.api.nvim_set_hl(highlight_ns, highlight_name, {
      link = M.prefix_highlight_name(opts.link),
      default = false,
    })
  else
    vim.api.nvim_set_hl(
      highlight_ns,
      highlight_name,
      colors_to_neovim_api(highlight_style)
    )
  end

  M._cache[opts.name] = {
    name = highlight_name,
  }

  return highlight_name
end

return M
