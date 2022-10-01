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

---@module "wut.workspace.decoration"

local Decorations = {}

function Decorations:new()
  local decorations = {
    _namespace = vim.api.nvim_create_namespace "@wut.workspace.decorations",
    _providers = {},
  }

  vim.api.nvim_set_decoration_provider(decorations._namespace, {
    on_win = function(_, ...)
      decorations:_handle_on_win(...)
    end,
    on_line = function(_, ...)
      decorations:_handle_on_line(...)
    end,
  })

  return setmetatable(decorations, {
    __index = self,
  })
end

---Register a new provider to handle buffer decorations
---@param provider table
function Decorations:register(provider)
  table.insert(self._providers, {
    id = #self._providers + 1,
    namespace = vim.api.nvim_create_namespace "wutgittest",
    provider = provider,
  })

  return true
end

function Decorations:_apply(items)
  -- TODO
end

function Decorations:_handle_on_win(...)
  for _, provider in ipairs(self._providers) do
    -- provider.provider.on_win(...)
  end
end

function Decorations:_handle_on_line(window, buffer, line_number)
  local filepath = vim.fn.expand(string.format("#%d:p", buffer))

  for _, provider in ipairs(self._providers) do
    provider.provider.on_line(filepath, line_number)
  end
end

function Decorations.set(id, decorations) end

function Decorations.clear(id) end

return Decorations
