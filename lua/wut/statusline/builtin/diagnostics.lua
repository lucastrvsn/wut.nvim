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

---@module "wut.statusline.builtin.diagnostics"

local t = require "wut/theme"

local function create_diagnostics_table(config)
  return {
    [vim.diagnostic.severity.ERROR] = config.error,
    [vim.diagnostic.severity.WARN] = config.warn,
    [vim.diagnostic.severity.INFO] = config.info,
    [vim.diagnostic.severity.HINT] = config.hint,
  }
end

local function count_severity_diagnostics(diagnostics)
  local count = create_diagnostics_table {
    error = 0,
    warn = 0,
    info = 0,
    hint = 0,
  }

  for _, diagnostic in ipairs(diagnostics) do
    count[diagnostic.severity] = count[diagnostic.severity] + 1
  end

  return count
end

local diagnostics_theme = create_diagnostics_table {
  error = {
    icon = t.ui "statusline.diagnostics.error",
    highlight = t.hl "statusline.diagnostics.error",
  },
  warn = {
    icon = t.ui "statusline.diagnostics.warn",
    highlight = t.hl "statusline.diagnostics.warn",
  },
  info = {
    icon = t.ui "statusline.diagnostics.info",
    highlight = t.hl "statusline.diagnostics.info",
  },
  hint = {
    icon = t.ui "statusline.diagnostics.hint",
    highlight = t.hl "statusline.diagnostics.hint",
  },
}

local M = {
  _autocmd_group = vim.api.nvim_create_augroup(
    "WutStatuslineBuiltinDiagnostics",
    {
      clear = true,
    }
  ),
}

M._diagnostics = create_diagnostics_table {
  error = 0,
  warn = 0,
  info = 0,
  hint = 0,
}

M.condition = function()
  for _, v in ipairs(M._diagnostics) do
    if v > 0 then
      return true
    end
  end

  return false
end

M.render = function()
  local result = {}

  for k, v in ipairs(M._diagnostics) do
    local format = diagnostics_theme[k]

    if v ~= 0 then
      table.insert(result, {
        content = format.icon .. tostring(v),
        highlight = format.highlight,
      })
    end
  end

  return {
    items = result,
  }
end

M.on_start = function()
  vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
    group = M._autocmd_group,
    pattern = { "*" },
    callback = function()
      local diagnostics = vim.diagnostic.get(nil, {
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
      })

      M._diagnostics = count_severity_diagnostics(diagnostics)
    end,
  })
end

M.on_exit = function() end

return M
