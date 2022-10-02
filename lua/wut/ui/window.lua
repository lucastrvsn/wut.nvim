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

---@module "wut.ui.window"

---@class Wut.UI.View
---@field init fun(): Wut.UI.View

---@class Wut.UI.Window.Options
---@field relative? string
---@field width? number
---@field height? number
---@field row? number
---@field col? number
---@field style? string
---@field border? string

---@class Wut.UI.Window
---@field _window_name? string
---@field _window_config Wut.UI.Window.Options
---@field _window_options table
---@field _namespace number
---@field _view? table | Wut.UI.View
local Window = {}

---@class Wut.UI.Window.New.Options
---@field name? string
---@field window Wut.UI.Window.Options
---@field options? table
---@field on_open? function
---@field on_close? function

local default_config = {
  relative = "editor",
  style = "minimal",
  border = "none",
}

---@param opts Wut.UI.Window.New.Options
---@return Wut.UI.Window
function Window:new(opts)
  vim.validate {
    name = { opts.name, "string", true },
    window = {
      opts.window,
      function(value)
        return pcall(vim.validate, {
          ["window.relative"] = { value.relative, "string", true },
          ["window.width"] = { value.width, "number", true },
          ["window.height"] = { value.height, "number", true },
          ["window.row"] = { value.row, "number", true },
          ["window.col"] = { value.col, "number", true },
          ["window.style"] = { value.style, "string", true },
          ["window.border"] = { value.border, "string", true },
        })
      end,
    },
    options = { opts.options, "table", true },
    on_open = { opts.on_open, "function", true },
    on_close = { opts.on_close, "function", true },
  }

  local window = {
    _buffer = nil,
    _namespace = vim.api.nvim_create_namespace(opts.name or nil),
    _user_on_close = opts.on_close,
    _user_on_open = opts.on_open,
    _window_config = opts.window or default_config,
    _window_name = opts.name,
    _window_options = opts.options or {},
  }

  return setmetatable(window, {
    __index = self,
  })
end

---@return Wut.UI.View | nil
function Window:get_view()
  return self._view
end

---@class Wut.UI.Window.Open.Options
---@field should_focus? boolean

---@param opts? Wut.UI.Window.Open.Options
function Window:open(opts)
  opts = opts or {}

  if self._view == nil then
    error(
      debug.traceback "A buffer needs to be attached to the window before open."
    )
  end

  if type(self._view.on_open) == "function" then
    self._view:on_open()
  end

  local handle = vim.api.nvim_open_win(
    self._view:render(),
    opts.should_focus or false,
    self._window_config
  )

  vim.api.nvim_win_set_hl_ns(handle, self._namespace)

  if vim.tbl_count(self._window_options) > 0 then
    for k, v in pairs(self._window_options) do
      vim.api.nvim_win_set_option(handle, k, v)
    end
  end
end

function Window:close()
  if type(self._view.on_close) == "function" then
    self._view:on_close()
  end
end

---@class Wut.UI.Attach.Constructor
---@field namespace number

---@param constructor fun(config: Wut.UI.Attach.Constructor): table | Wut.UI.View
---@return Wut.UI.Window
function Window:attach(constructor)
  if type(constructor) ~= "function" then
    error(debug.traceback "constructor needs to be a function")
  end

  local ok, returned_view = pcall(constructor, {
    namespace = self._namespace,
  })

  if not ok then
    error(debug.traceback(returned_view))
  end

  if type(returned_view) ~= "table" then
    error(
      debug.traceback "the value returned from `constructor` should be a table"
    )
  end

  self._view = returned_view

  return self
end

function Window:set_option()
  -- TODO
end

return Window
