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

---@module "wut.statusline.modules"

local renderer = require "wut/statusline/renderer"

local M = {
  _worker = nil,
  _modules = {
    active = {
      left = {},
      center = {},
      right = {},
    },
    inactive = {
      left = {},
      center = {},
      right = {},
    },
  },
}

M.add_module = function(opts)
  local state = opts[1]
  local position = opts[2]

  vim.validate {
    state = {
      state,
      "string",
    },
    position = {
      position,
      "string",
    },
  }

  return function(module)
    vim.validate {
      module = {
        module,
        "table",
      },
      render = {
        module.render,
        "function",
      },
      condition = {
        module.condition,
        "function",
        true,
      },
      on_start = {
        module.on_start,
        "function",
        true,
      },
      on_exit = {
        module.on_exit,
        "function",
        true,
      },
    }

    if type(module.on_start) == "function" then
      module.on_start()
    end

    table.insert(M._modules[state][position], module)
  end
end

M.build = function(state)
  local modules = M._modules[state]

  return string.format(
    "%s%%=%s%%=%s",
    renderer.render(modules.left),
    renderer.render(modules.center),
    renderer.render(modules.right)
  )
end

return M
