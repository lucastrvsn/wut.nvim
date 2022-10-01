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

local core = require "wut/core"
local workspace = require "wut/workspace"
local statusline = require "wut/statusline"
local explorer = require "wut/explorer"

local function setup()
  vim.opt.termguicolors = true
  vim.cmd [[
    try
      colorscheme koehler
    catch /^Vim\%((\a\+)\)\=:E185/
      " TODO: handle error
    endtry
  ]]

  core.init()

  workspace.setup()

  explorer.setup()

  -- {
  --   {
  --     mode,
  --     git-branch,
  --     diagnostics,
  --   },
  --   {
  --     file-icon?,
  --     file-name,
  --     modified,
  --   },
  --   {
  --     filetype,
  --     fileenconding,
  --     fileposition,
  --   },
  -- }
  statusline.setup {
    active = function(append)
      append.left(require "wut/statusline/builtin/mode")
      append.left(require "wut/statusline/builtin/spacer")
      append.left(require "wut/statusline/builtin/diagnostics")

      append.center(require "wut/statusline/builtin/filemodified")
      append.center(require "wut/statusline/builtin/spacer")
      append.center(require "wut/statusline/builtin/filename")

      append.right(require "wut/statusline/builtin/filetype")
      append.right(require "wut/statusline/builtin/fileencoding")
      append.right(require "wut/statusline/builtin/spacer")
      append.right(require "wut/statusline/builtin/scroll")
    end,
    inactive = function(append)
      append.left {
        render = function()
          return "inactive"
        end,
      }
    end,
  }

  workspace.register_provider("scm", {
    init = function()
      vim.pretty_print "test"
    end,
  })

  -- workspace.register_provider("hover", {
  --   filetypes = { "lua" },
  --   handler = function(args)
  --     vim.pretty_print(args)
  --     return "teste"
  --   end,
  -- })

  -- workspace.register_provider("git", git)

  -- local Window = require "wut/ui/window"
  -- local f = require "wut/ui/fragment"
  -- local use_state = require "wut/ui/use_state"
  -- local use_effect = require "wut/ui/use_effect"
  -- local use_cursor = require "wut/ui/use_cursor"
  -- local ui = require "wut/ui"
  --
  -- ui.setup()
  --
  -- local window = Window:new(function()
  --   local s, set_s = use_state "my_cool_string"
  --   local n, set_n = use_state(0)
  --   local cursor = use_cursor {
  --     on_move = function()
  --       set_s "my cursor moved!!!!!"
  --     end,
  --   }
  --
  --   use_effect(function()
  --     set_n(function(prev)
  --       return prev + 1
  --     end)
  --   end, {})
  --
  --   use_effect(function()
  --     vim.pretty_print "timer 1"
  --
  --     local timer = vim.loop.new_timer()
  --     timer:start(2000, 0, function()
  --       set_s "another_string"
  --       vim.pretty_print(s)
  --       timer:close()
  --     end)
  --   end, {})
  --
  --   return f { "oi" }
  -- end)
  --
  -- ui.register_window(window)
  --
  -- vim.keymap.set("n", "<Leader>-", function()
  --   window:open()
  -- end)
end

setup()
