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

---@module "wut.statusline.builtin.spacer"

local t = require "wut/theme"

local symbols = {
  fade = {
    "░",
    "░",
    "▒",
    "▒",
    "▓",
    "▓",
    "█",
    "█",
  },
  fill_right = {
    "▎",
    "▍",
    "▌",
    "▋",
    "▊",
    "▉",
    "█",
    "█",
  },
  fill_up = {
    "▁",
    "▂",
    "▃",
    "▄",
    "▅",
    "▆",
    "▇",
    "█",
  },
  dice = {
    "□",
    "⚀",
    "⚁",
    "⚂",
    "⚃",
    "⚄",
    "⚅",
    "■",
  },
}

local M = {}

M.render = function()
  local total_lines = vim.api.nvim_buf_line_count(0)

  -- Don't divide by zero in any situation!
  if total_lines == 0 then
    total_lines = 1
  end

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local percentage = current_line / total_lines
  local position = math.floor(percentage * 7)

  return {
    content = symbols.fill_right[position + 1],
    highlight = t.hl "statusline.scroll",
  }
end

return M
