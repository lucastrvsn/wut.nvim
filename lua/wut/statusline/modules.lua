local renderer = require "wut/statusline/renderer"

local M = {
  _worker = nil,
  _modules = {
    active = {
      left = {},
      center = {},
      right = {},
    },
    inactive = {
      left = {},
      center = {},
      right = {},
    },
  },
}

M.add_module = function(opts)
  local state = opts[1]
  local position = opts[2]

  vim.validate {
    state = {
      state,
      "string",
    },
    position = {
      position,
      "string",
    },
  }

  return function(module)
    vim.validate {
      module = {
        module,
        "table",
      },
      render = {
        module.render,
        "function",
      },
      condition = {
        module.condition,
        "function",
        true,
      },
      on_start = {
        module.on_start,
        "function",
        true,
      },
      on_exit = {
        module.on_exit,
        "function",
        true,
      },
    }

    if type(module.on_start) == "function" then
      module.on_start()
    end

    table.insert(M._modules[state][position], module)
  end
end

M.build = function(state)
  local modules = M._modules[state]

  return string.format(
    "%s%%=%s%%=%s",
    renderer.render(modules.left),
    renderer.render(modules.center),
    renderer.render(modules.right)
  )
end

return M
