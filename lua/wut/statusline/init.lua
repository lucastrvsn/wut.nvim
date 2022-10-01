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

---@module "wut.statusline"

local add_modules = require("wut/statusline/modules").add_module

local M = {
  _namespace = vim.api.nvim_create_namespace "WutStatusline",
  _autocmd_group = vim.api.nvim_create_augroup("wut/statusline", {
    clear = true,
  }),
}

M.redraw = function()
  vim.o.statusline = require("wut/statusline/modules").build "active"
end

M.on_enter = function()
  -- vim.o.statusline =
  --   [[%!luaeval('')]]
end

M.on_leave = function()
  -- vim.o.statusline = [[%!luaeval('require("wut/statusline/modules").build("inactive")')]]
end

M.setup = function(config)
  vim.validate {
    config = {
      config,
      "table",
    },
    ["config.active"] = {
      config.active,
      "function",
    },
    ["config.inactive"] = {
      config.inactive,
      "function",
      true,
    },
  }

  -- Parse user config
  config.active {
    left = add_modules { "active", "left" },
    center = add_modules { "active", "center" },
    right = add_modules { "active", "right" },
  }
  config.inactive {
    left = add_modules { "inactive", "left" },
    center = add_modules { "inactive", "center" },
    right = add_modules { "inactive", "right" },
  }

  -- vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  --   group = M.autocmd_group,
  --   pattern = "*",
  --   callback = require("wut/statusline").on_enter,
  -- })
  -- vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  --   group = M.autocmd_group,
  --   pattern = "*",
  --   callback = require("wut/statusline").on_leave,
  -- })

  -- require("wut/statusline/events").subscribe(function()
  --   vim.o.statusline = require("wut/statusline/modules").build "active"
  -- end)
  --

  vim.api.nvim_create_autocmd({
    "WinEnter",
    "BufEnter",
    "SessionLoadPost",
    "FileChangedShellPost",
    "VimResized",
    "Filetype",
    "ModeChanged",
    "CursorMoved",
    "DiagnosticChanged",
  }, {
    group = M._autocmd_group,
    pattern = "*",
    callback = M.redraw,
  })
end

return M
