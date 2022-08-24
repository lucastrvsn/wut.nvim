local t = require "wut/theme"

local M = {
  _modes = {
    ["n"] = {
      text = "normal",
      highlight = t.hl "StatuslineModeNormal",
    },
    ["no"] = {
      text = "n operator pending",
      highlight = t.hl "StatuslineModeNormal",
    },
    ["v"] = {
      text = "visual",
      highlight = t.hl "StatuslineModeVisual",
    },
    ["V"] = {
      text = "v-line",
      highlight = t.hl "StatuslineModeVisual",
    },
    [""] = {
      text = "v-block",
      highlight = t.hl "StatuslineModeVisual",
    },
    ["s"] = {
      text = "select",
      highlight = t.hl "StatuslineModeSelect",
    },
    ["S"] = {
      text = "s-line",
      highlight = t.hl "StatuslineModeSelect",
    },
    ["^S"] = {
      text = "s-block",
      highlight = t.hl "StatuslineModeSelect",
    },
    ["i"] = {
      text = "insert",
      highlight = t.hl "StatuslineModeInsert",
    },
    ["ic"] = {
      text = "insert",
      highlight = t.hl "StatuslineModeInsert",
    },
    ["ix"] = {
      text = "insert",
      highlight = t.hl "StatuslineModeInsert",
    },
    ["R"] = {
      text = "replace",
      highlight = t.hl "StatuslineModeReplace",
    },
    ["Rv"] = {
      text = "v-replace",
      highlight = t.hl "StatuslineModeReplace",
    },
    ["c"] = {
      text = "command",
      highlight = t.hl "StatuslineModeCommand",
    },
    ["cv"] = {
      text = "vim ex",
      highlight = t.hl "StatuslineModeCommand",
    },
    ["r"] = {
      text = "prompt",
      highlight = t.hl "StatuslineModePrompt",
    },
    ["rm"] = {
      text = "more",
      highlight = t.hl "StatuslineModePrompt",
    },
    ["r?"] = {
      text = "confirm",
      highlight = t.hl "StatuslineModePrompt",
    },
    ["!"] = {
      text = "shell",
      highlight = t.hl "StatuslineModeShell",
    },
    ["t"] = {
      text = "terminal",
      highlight = t.hl "StatuslineModeTerminal",
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
