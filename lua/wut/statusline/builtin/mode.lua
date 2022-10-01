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

---@module "wut.statusline.builtin.mode"

local t = require "wut/theme"

local M = {
  _modes = {
    ["n"] = {
      text = "normal",
      highlight = t.hl "statusline.mode.normal",
    },
    ["no"] = {
      text = "n operator pending",
      highlight = t.hl "statusline.mode.normal",
    },
    ["v"] = {
      text = "visual",
      highlight = t.hl "statusline.mode.visual",
    },
    ["V"] = {
      text = "v-line",
      highlight = t.hl "statusline.mode.visual",
    },
    [""] = {
      text = "v-block",
      highlight = t.hl "statusline.mode.visual",
    },
    ["s"] = {
      text = "select",
      highlight = t.hl "statusline.mode.select",
    },
    ["S"] = {
      text = "s-line",
      highlight = t.hl "statusline.mode.select",
    },
    ["^S"] = {
      text = "s-block",
      highlight = t.hl "statusline.mode.select",
    },
    ["i"] = {
      text = "insert",
      highlight = t.hl "statusline.mode.insert",
    },
    ["ic"] = {
      text = "insert",
      highlight = t.hl "statusline.mode.insert",
    },
    ["ix"] = {
      text = "insert",
      highlight = t.hl "statusline.mode.insert",
    },
    ["R"] = {
      text = "replace",
      highlight = t.hl "statusline.mode.replace",
    },
    ["Rv"] = {
      text = "v-replace",
      highlight = t.hl "statusline.mode.replace",
    },
    ["c"] = {
      text = "command",
      highlight = t.hl "statusline.mode.command",
    },
    ["cv"] = {
      text = "vim ex",
      highlight = t.hl "statusline.mode.command",
    },
    ["r"] = {
      text = "prompt",
      highlight = t.hl "statusline.mode.prompt",
    },
    ["rm"] = {
      text = "more",
      highlight = t.hl "statusline.mode.prompt",
    },
    ["r?"] = {
      text = "confirm",
      highlight = t.hl "statusline.mode.prompt",
    },
    ["!"] = {
      text = "shell",
      highlight = t.hl "statusline.mode.shell",
    },
    ["t"] = {
      text = "terminal",
      highlight = t.hl "statusline.mode.terminal",
    },
  },
}

M.render = function()
  local mode = M._modes[vim.api.nvim_get_mode().mode]

  if not mode then
    return "unknown"
  end

  return {
    content = string.format(" %s ", mode.text),
    highlight = mode.highlight,
  }
end

return M
