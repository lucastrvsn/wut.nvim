local M = {
  autocmd_group = vim.api.nvim_create_augroup("wut/statusline/events", {
    clear = true,
  }),
  timer = vim.loop.new_timer(),
  listeners = {},
}

M.on_change = require("wut/utils/functions").throttle(function(...)
  for _, callback in ipairs(M.listeners) do
    callback(...)
  end
end, 250)

M.subscribe = function(callback)
  vim.validate {
    callback = {
      callback,
      "function",
    },
  }

  table.insert(M.listeners, callback)
end

M.init = function()
  vim.api.nvim_create_autocmd({
    -- Built-in neovim events
    "BufEnter",
    "BufLeave",
    "BufWritePost",
    "ChanInfo",
    "CmdlineEnter",
    "CmdlineLeave",
    "CursorMoved",
    "CursorMovedI",
    "FileType",
    "FocusGained",
    "FocusLost",
    "ModeChanged",
    "TextChanged",
    "TextChangedI",
    "VimEnter",
    "VimResized",
    "VimResume",
    "VimSuspend",
    "WinEnter",
    "WinLeave",
    "WinScrolled",

    -- LSP specific events
    "LspAttach",
    "LspDetach",
    "DiagnosticChanged",
  }, {
    group = M.autocmd_group,
    pattern = "*",
    desc = "Listen to events from neovim to update the statusline.",
    callback = M.on_change,
  })
end

return M
