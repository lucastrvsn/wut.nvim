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
