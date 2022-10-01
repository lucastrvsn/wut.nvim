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

---@module "wut.theme.colors"

local color = require "wut/color"

-- Base16 colors
-- See: https://github.com/chriskempson/base16
local M = {
  base00 = color.from "#282828", -- Default Background
  base01 = color.from "#3c3836", -- Lighter Background (Used for status bars, line number and folding marks)
  base02 = color.from "#504945", -- Selection Background
  base03 = color.from "#665c54", -- Comments, Invisibles, Line Highlighting
  base04 = color.from "#bdae93", -- Dark Foreground (Used for status bars)
  base05 = color.from "#d5c4a1", -- Default Foreground, Caret, Delimiters, Operators
  base06 = color.from "#ebdbb2", -- Light Foreground (Not often used)
  base07 = color.from "#fbf1c7", -- Light Background (Not often used)
  base08 = color.from "#fb4934", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = color.from "#fe8019", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0a = color.from "#fabd2f", -- Classes, Markup Bold, Search Text Background
  base0b = color.from "#b8bb26", -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0c = color.from "#8ec07c", -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0d = color.from "#83a598", -- Functions, Methods, Attribute IDs, Headings
  base0e = color.from "#d3869b", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0f = color.from "#d65d0e", -- Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
}

return M
