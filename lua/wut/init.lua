local workspace = require "wut/workspace"
local git = require "wut/git"
local statusline = require "wut/statusline"

local M = {}

M.setup = function()
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

  local Fragment = require "wut/ui/fragment"
  local use_state = require "wut/ui/use_state"
  local EventTypes = require "wut/events/types"

  local s, set_s = use_state "my_cool_string"

  local w = require("wut/ui/window"):new {
    render = function()
      return { "oi" .. s }
    end,
  }
  set_s "another_string"

  -- local w = require("wut/ui/window"):new {
  --   options = {
  --     close_when_unfocus = true,
  --   },
  --   view = Fragment:new {
  --     state = {
  --       index = 0,
  --     },
  --     events = {
  --       EventTypes.Ready,
  --     },
  --     on_update = function(state, set_state)
  --       set_state { index = state.index + 1 }
  --       return true
  --     end,
  --     render = function(state)
  --       return {
  --         Fragment:new {
  --           render = function()
  --             return "Files " .. state.index
  --           end,
  --         },
  --         Fragment:new {
  --           render = function()
  --             return result
  --           end,
  --         },
  --       }
  --     end,
  --   },
  -- }

  vim.keymap.set("n", "<Leader>-", function()
    w:open()
  end)
end

return M
