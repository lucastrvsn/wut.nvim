local Files = require "wut/workspace/files"

local M = {}

M.setup = function(opts)
  opts = opts or {}

  local cwd = opts.cwd or vim.fn.getcwd()

  M.files = Files:new {
    cwd = require("wut/git/helpers").get_git_root(cwd),
    ignore_patterns = {
      [".git"] = true,
      ["node_modules"] = true,
    },
  }
end

return M
