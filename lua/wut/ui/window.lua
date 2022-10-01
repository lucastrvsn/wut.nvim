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

local Window = {}

local default_config = {
  relative = "editor",
  style = "minimal",
  border = "none",
}

function Window:new(view, opts)
  local window = {
    _namespace = nil,
    _view = nil,
    _window_name = nil,
    _window_config = default_config,
    _window_options = {},
  }

  if type(opts) ~= "table" then
    error(debug.traceback "config needs to be a table")
  end

  if type(opts.name) ~= "string" then
    error(debug.traceback "window needs to a name")
  end

  window._window_name = opts.name
  window._namespace = vim.api.nvim_create_namespace(window._window_name)

  if type(opts.window) == "table" then
    window._window_config = opts.window
  end

  if type(opts.options) == "table" then
    window._window_options = opts.options
  end

  if type(view) ~= "function" then
    error(debug.traceback "view needs to be a function")
  end

  local ok, new_view = pcall(view, {
    namespace = window._namespace,
  })

  if not ok then
    error(debug.traceback(new_view))
  end

  window._view = new_view

  return setmetatable(window, {
    __index = self,
  })
end

function Window:open(focus)
  focus = focus or false

  self:view():on_open()

  local handle =
    vim.api.nvim_open_win(self._view:render(), focus, self._window_config)

  vim.api.nvim_win_set_hl_ns(handle, self._namespace)

  if vim.tbl_count(self._window_options) > 0 then
    for k, v in pairs(self._window_options) do
      vim.api.nvim_win_set_option(handle, k, v)
    end
  end
end

function Window:close()
  self:view():on_close()
end

function Window:view()
  return self._view
end

function Window:namespace()
  return self._namespace
end

function Window:set_option() end

return Window
