local workspace = require "wut/workspace"
local git = require "wut/git"
local statusline = require "wut/statusline"

local M = {}

M.setup = function()
  require("wut/core").init()

  workspace.setup {}

  git.setup {}

  statusline.setup {
    active = function(add)
      add.left(require "wut/statusline/builtin/mode")

      add.left(require "wut/statusline/builtin/diagnostics")

      add.center(require "wut/statusline/builtin/filename")

      add.right {
        render = function()
          return "right"
        end,
      }
    end,
    inactive = function(add)
      add.left {
        render = function()
          return "inactive"
        end,
      }
    end,
  }

  local Window = require "wut/ui/window"
  local f = require "wut/ui/fragment"
  local use_state = require "wut/ui/use_state"
  local use_effect = require "wut/ui/use_effect"
  local use_cursor = require "wut/ui/use_cursor"
  local ui = require "wut/ui"

  local Promise = require "wut/core/promise"
  Promise:new(function(resolve, reject)
    local tt = vim.loop.new_timer()
    tt:start(
      1000,
      0,
      vim.schedule_wrap(function()
        tt:close()

        require("wut/git/helpers")
          .git_root(vim.fn.getcwd())
          :next(resolve)
          :catch(reject)
          :start()
      end)
    )
  end)
    :next(function(result)
      print("data received 1:", result)
    end)
    :catch(function(err)
      vim.pretty_print("error:::::", err)
    end)
    :start()

  ui.setup()

  local window = Window:new(function()
    local s, set_s = use_state "my_cool_string"
    local n, set_n = use_state(0)
    local cursor = use_cursor {
      on_move = function()
        set_s "my cursor moved!!!!!"
      end,
    }

    use_effect(function()
      set_n(function(prev)
        return prev + 1
      end)
    end, {})

    use_effect(function()
      vim.pretty_print "timer 1"

      local timer = vim.loop.new_timer()
      timer:start(2000, 0, function()
        set_s "another_string"
        vim.pretty_print(s)
        timer:close()
      end)
    end, {})

    return f { "oi" }
  end)

  ui.register_window(window)

  vim.keymap.set("n", "<Leader>-", function()
    window:open()
  end)
end

return M
