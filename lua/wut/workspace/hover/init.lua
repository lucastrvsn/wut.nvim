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

---@module "wut.workspace.hover"

local Hover = {}

function Hover:new()
  local hover = {
    _providers = {},
  }

  vim.schedule(function()
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
      pattern = "*",
      callback = function(...)
        hover:collect(...)
      end,
    })
  end)

  return setmetatable(hover, {
    __index = self,
  })
end

function Hover:register(provider)
  if type(provider) ~= "table" then
    error(debug.traceback())
  end

  if type(provider.handler) ~= "function" then
    error(debug.traceback())
  end

  table.insert(self._providers, provider)

  return true
end

---@class Wut.Workspace.Hover.Collect.CallbackArguments
---@field buf number
---@field event "CursorHold"
---@field file string
---@field id number
---@field match string

---@class Wut.Workspace.Hover.Collect.Arguments
---@field buffer number
---@field path string
---@field line number
---@field column number

---@param args Wut.Workspace.Hover.Collect.CallbackArguments
function Hover:collect(args)
  local items = {}
  local current_line = vim.api.nvim_win_get_cursor(0)
  local handler_args = {
    buffer = args.buf,
    path = args.file,
    line = current_line[1],
    column = current_line[2],
  }

  vim.pretty_print(vim.lsp.buf.references())

  for _, provider in ipairs(self._providers) do
    local result = provider.handler(handler_args)
    if result then
      table.insert(items, result)
    end
  end

  self:commit(items)
end

function Hover:commit(items)
  vim.pretty_print(items)
end

return Hover
