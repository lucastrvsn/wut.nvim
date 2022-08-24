local Stack = require "wut/utils/stack"
local events = require "wut/events"
local EventTypes = require "wut/events/types"

local Window = {}

function Window:new(opts)
  local window = {
    ___type = "UIWindow",
    ___win = nil,
    ___bufnr = nil,
    ___options = nil,
    ___view = nil,
  }

  window.___bufnr = vim.api.nvim_create_buf(false, false)
  assert(window.___bufnr ~= 0)

  window.___options = opts.options or {}
  window.___view = opts.view or {}

  window.___render = opts.render
  if type(window.___render) ~= "function" then
    vim.pretty_print "ERROR"
  end

  events.subscribe(EventTypes.UIWindowUpdate, function()
    window:_render()
    vim.pretty_print "update"
  end)

  return setmetatable(window, {
    __index = self,
  })
end

function Window:on_init()
  vim.pretty_print "panel init"
end

function Window:on_exit()
  vim.pretty_print "panel exit"
end

function Window:on_open()
  self:_render()

  if self.___options.close_when_unfocus then
    vim.api.nvim_create_autocmd({ "WinLeave" }, {
      buffer = self.___bufnr,
      callback = function()
        self:close()
      end,
    })
  end

  vim.keymap.set("n", "<Leader>.", function()
    self:close()
  end, {
    buffer = self.___bufnr,
  })
end

function Window:on_close()
  vim.pretty_print "im closing..."
end

function Window:_render()
  local r = self.___render()
  vim.pretty_print(r)
end

function Window:render()
  local result = {}
  local stack = Stack:new()
  stack:push(self.___view)

  while not stack:is_empty() do
    local view = stack:pop()
    local render = view:render(view:get_state())

    if type(render) == "string" then
      table.insert(result, render)
    elseif type(render) == "table" then
      for _, f in ipairs(render) do
        if f.___type == "UIFragment" then
          stack:push(f)
          goto continue
        end

        if type(f) == "string" then
          table.insert(result, f)
        elseif type(f) == "function" then
          table.insert(result, f())
        end

        ::continue::
      end
    end
  end

  vim.api.nvim_buf_set_lines(self.___bufnr, 0, -1, false, result)
end

function Window:open()
  self:on_open()

  self.___win = vim.api.nvim_open_win(self.___bufnr, true, {
    relative = "editor",
    width = 100,
    height = 6,
    row = 20,
    col = 20,
    style = "minimal",
    border = "single",
  })

  vim.api.nvim_set_current_win(self.___win)
end

function Window:close()
  if self.___win ~= nil then
    vim.api.nvim_win_close(self.___win, false)
    self.___win = nil
  end
end

return Window
