local ui = require "wut/ui"
local use_state = require "wut/ui/use_state"
local use_effect = require "wut/ui/use_effect"

return function(opts)
  local cursor, set_cursor = use_state { name = "teste2" }
  local cursor_position, set_cursor_position = use_state {
    row = vim.api.nvim_win_get_cursor(0)[1],
    col = vim.api.nvim_win_get_cursor(0)[2],
  }

  use_effect(function() end, {})

  return cursor_position
end
