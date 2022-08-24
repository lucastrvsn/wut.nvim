local t = require "wut/theme"

local M = {
  _autocmd_group = vim.api.nvim_create_augroup(
    "WutStatuslineBuiltinDiagnostics",
    {
      clear = true,
    }
  ),
}

local create_diagnostics_table = function(config)
  return {
    [vim.diagnostic.severity.ERROR] = config.error,
    [vim.diagnostic.severity.WARN] = config.warn,
    [vim.diagnostic.severity.INFO] = config.info,
    [vim.diagnostic.severity.HINT] = config.hint,
  }
end

local count_severity_diagnostics = function(diagnostics)
  local count_diagnostics = create_diagnostics_table {
    error = 0,
    warn = 0,
    info = 0,
    hint = 0,
  }

  for _, v in ipairs(diagnostics) do
    count_diagnostics[v.severity] = count_diagnostics[v.severity] + 1
  end

  return count_diagnostics
end

M._format = create_diagnostics_table {
  error = {
    icon = t.ui "StatuslineDiagnosticsError",
    highlight = t.hl "StatuslineDiagnosticsError",
  },
  warn = {
    icon = t.ui "StatuslineDiagnosticsWarn",
    highlight = t.hl "StatuslineDiagnosticsWarn",
  },
  info = {
    icon = t.ui "StatuslineDiagnosticsInfo",
    highlight = t.hl "StatuslineDiagnosticsInfo",
  },
  hint = {
    icon = t.ui "StatuslineDiagnosticsHint",
    highlight = t.hl "StatuslineDiagnosticsHint",
  },
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
    local format = M._format[k]

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
