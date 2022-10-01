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

---@module "wut.core.thread"

---@class Thread.Params
---@field id string
---@field priority number
---@field args any
---@field status Thread.State
---@field value? any

local Thread = {}

---@enum Thread.State
Thread.State = {
  READY = 1,
  RUNNING = 2,
  WAITING = 3,
  CHECKING = 4,
  ERROR = 5,
}

---@class Thread.Create.Options
---@field priority? integer

---@param fn function | thread
---@param opts? Thread.Create.Options
---@param ... any
---@return thread, Thread.Params
Thread.create = function(fn, opts, ...)
  local _opts = opts or {}

  ---@diagnostic disable-next-line
  vim.validate {
    ["fn"] = { fn, { "function", "thread" } },
    ["opts"] = { _opts, "table", true },
    ["opts.priority"] = { _opts.priority, "number", true },
  }

  local thread
  if type(fn) == "thread" then
    thread = fn
  else
    thread = coroutine.create(
      fn --[[@as function]]
    )
  end

  local params = {
    id = vim.fn.id(tostring(thread)),
    priority = _opts.priority or 0,
    args = { ... },
    status = Thread.State.READY,
    value = nil,
  }

  return thread --[[@as thread]],
    params
end

Thread.to_string = function(params)
  return string.format(
    "An error occoured inside this thread. ID: %s, PRIORITY: %s, STATUS: %s",
    params.id,
    params.priority,
    params.status
  )
end

return Thread
