local color = require "wut/color"

local M = {
  _prefix = "Wut",
  _cache = {},
}

local scope_highlight = function(name)
  return string.format("%s%s", M._prefix, name)
end

local colors_to_neovim_api = function(colors)
  local result = {}

  for k, v in pairs(colors) do
    if type(v) == "table" and v._type == "Color" then
      result[k] = color.to_hex(v)
    end
  end

  return result
end

M.get = function(name)
  local value = M._cache[name]

  if value ~= nil then
    return value.name
  end

  return nil
end

M.create = function(opts)
  assert(type(opts.name) == "string")

  if M.get(opts.name) ~= nil then
    vim.cmd(
      string.format(
        [[WutHighlight: highlight name "%s" already exists]],
        opts.name
      )
    )
  end

  local highlight_name = scope_highlight(opts.name)
  local highlight_ns = opts.namespace or 0
  local highlight_style = opts.style or {}

  if type(opts.link) == "string" then
    vim.api.nvim_set_hl(highlight_ns, highlight_name, {
      link = M.prefix_highlight_name(opts.link),
      default = false,
    })
  else
    vim.api.nvim_set_hl(
      highlight_ns,
      highlight_name,
      colors_to_neovim_api(highlight_style)
    )
  end

  M._cache[opts.name] = {
    name = highlight_name,
  }

  return highlight_name
end

return M
