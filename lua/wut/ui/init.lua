--- @module "ui"

--[[
Copyright (c) 2022 by Lucas Trevisan (lucastrvsn@gmail.com)

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

--- @class Action
--- @field coroutine thread
--- @field args table
--- @field priority number
--- @field next? Action

---@class M
---@field _windows Window[]
---@field _co thread | nil
---@field _actions Action[]
local M = {
  _windows = {},
  _co = nil,
  _actions = {},
}

---@param fn thread | function
---@return thread
local to_coroutine = function(fn)
  if type(fn) == "thread" then
    return fn
  end

  if type(fn) == "function" then
    return coroutine.create(fn)
  end

  error "fn needs to be a function"
end

---@class create_action.opts
---@field fn function
---@field priority integer
---@field args any

---@param opts create_action.opts The action to be created
---@param ... any Arguments to be passed down to coroutine
---@return Action
---Return a new action table
local create_action = function(opts, ...)
  return {
    coroutine = to_coroutine(opts.fn),
    priority = opts.priority or 0,
    args = { ... },
  }
end

M._schedule_ui_update = function()
  M.schedule(create_action {
    fn = M.run_render,
  })
end

---@param window Window
---@return nil
---Register a new window to be managed
M.register_window = function(window)
  if type(window) == "table" and window.___type == "UIWindow" then
    window.___id = #M._windows + 1

    if pcall(window.on_init, window) then
      table.insert(M._windows, window)
    end

    M._schedule_ui_update()
  end
end

---@param action Action
---@return nil
---Register a new action to be handled and sort the table of actions to put
---the most priority action in the top of the list
M.schedule = function(action)
  table.insert(M._actions, action)

  -- We don't want to sort if the priority is not greater then 0
  if action.priority > 0 then
  end
end

---@param fn function
---@param should_trigger_update? boolean
M.dispatch = function(fn, should_trigger_update)
  return function(...)
    M.schedule(create_action({
      fn = fn,
      priority = 10,
    }, ...))

    if should_trigger_update then
      M._schedule_ui_update()
    end

    if coroutine.status(M._co) == "suspended" then
      coroutine.resume(M._co)
    end
  end
end

M.run_render = function()
  for _, window in ipairs(M._windows) do
    window:render()
  end
end

M.async = function(fn)
  return function(...)
    local _args = { ... }
    local _coroutine = assert(coroutine.running())
    vim.schedule(function()
      fn(unpack(_args))
      coroutine.resume(_coroutine)
    end)
  end
end

M.run = function()
  while true do
    if not vim.in_fast_event() then
      while #M._actions > 0 do
        local action = table.remove(M._actions, 1)
        local status, err =
          coroutine.resume(action.coroutine, unpack(action.args))

        if not status and err then
          local trace = debug.traceback()
          vim.pretty_print(trace)
          error(trace)
        elseif coroutine.status(action.coroutine) ~= "dead" then
          table.insert(M._actions, action)
        end
      end
    end

    coroutine.yield()
  end
end

M.setup = function()
  M._co = coroutine.create(M.run)
  coroutine.resume(M._co)
end

M.error = function()
  local trace = debug.traceback()
end

return M
