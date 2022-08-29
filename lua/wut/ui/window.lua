local renderer = require "wut/ui/renderer"
local hooks = require "wut/ui/hooks"

---@class Component

---@class WindowOptions
---@field should_close boolean

---@class Window
---@field ___type "UIWindow"
---@field ___id integer | nil
---@field ___win integer | nil
---@field ___bufnr integer | nil
---@field ___root_component Component
---@field ___options WindowOptions
local Window = {}

---@param root Component
---@param opts WindowOptions
---@return Window
function Window:new(root, opts)
  local window = {
    ___type = "UIWindow",
    ___id = nil,
    ___win = nil,
    ___bufnr = nil,
    ___root_component = nil,
    ___options = nil,
  }

  if type(root) ~= "function" then
    error "should be function"
  end

  window.___root_component = root

  if opts and type(opts) ~= "table" then
    vim.pretty_print "ERROR"
  end

  window.___options = opts or {}

  return setmetatable(window, {
    __index = self,
  })
end

function Window:on_init()
  self.___bufnr = vim.api.nvim_create_buf(false, true)

  if self.___bufnr == 0 then
    error "ERROR"
  end

  vim.pretty_print "Hello!"

  return true
end

function Window:on_exit()
  vim.pretty_print "Goodbye."
end

function Window:on_open()
  vim.api.nvim_create_autocmd({ "WinLeave" }, {
    buffer = self.___bufnr,
    callback = function()
      self:close()
    end,
  })

  vim.keymap.set("n", "<ESC>", function()
    self:close()
  end, {
    buffer = self.___bufnr,
  })
end

function Window:on_close()
  vim.pretty_print "im closing..."
end

function Window:render()
  _G._wut_current_window = self.___id

  local result = renderer.render(self.___root_component)

  hooks.reset()

  if type(result) == "string" then
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(self.___bufnr, 0, -1, false, { result })
    end)
  end
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
