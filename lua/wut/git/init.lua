local Repository = require "wut/git/repository"

local M = {
  repository = nil,
}

M.setup = function(opts)
  M.repository = Repository:new()
  if not M.repository:is_repository() then
    vim.pretty_print "not in git repo"
  end

  vim.keymap.set("n", "<Leader>gl", function()
    local row, c = unpack(vim.api.nvim_win_get_cursor(0))
    local filepath = vim.fn.expand "%:p"

    M.repository:blame_line(filepath, row)
  end)

  vim.keymap.set("n", "<Leader>gs", function()
    M.repository:status()
  end)

  vim.keymap.set("n", "<Leader>gd", function()
    M.repository:diff(vim.fn.expand "%:p")
  end)

  vim.keymap.set("n", "<Leader>gf", function()
    M.repository:diff_files()
  end)

  M.repository:diff_from_text(vim.fn.expand "%:p", "my file content")
end

return M
