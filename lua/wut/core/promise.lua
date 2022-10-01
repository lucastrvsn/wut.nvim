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

---@module "wut.core.promise"

local core = require "wut/core"
local is_function = require("wut/utils/functions").is_function

---@class Promise
---@field ["@@type"] "Promise" The identifier of this object
---@field _thread string The scheduler thread this promise will be run.
---@field _executor function(resolve, reject) Function to be executed asyncronusly and will call `resolve` or `reject`.
---@field _state Promise.State Current state of the Promise. "pending", "resolved", "rejected".
---@field _data any The data returned by the resolver callback.
---@field _cb_resolve function[]
---@field _cb_reject function[]

local Promise = {}

---@enum Promise.State
Promise.State = {
  PENDING = "pending",
  RESOLVED = "resolved",
  REJECTED = "rejected",
}

---Create a new Promise to be handled by the scheduler
---@param executor fun(resolve: fun(...), reject?: fun(...))
function Promise:new(executor)
  local promise = {
    ["@@type"] = "Promise",
    _data = nil,
    _cb_resolve = {},
    _cb_reject = {},
  }

  if not is_function(executor) then
    error "not a function"
  end

  promise._executor = executor
  promise._state = Promise.State.PENDING

  return setmetatable(promise, {
    __index = self,
  })
end

---Create the callback that is going to be pass to the initial function. Internal use only.
---@param state Promise.State
---@return function
function Promise:_resolver(state)
  return function(...)
    self._state = state
    self._data = { ... }
    vim.pretty_print("to aqui", state, ...)
  end
end

---Handle the promise resolved state.
function Promise:_handle()
  if self._state ~= Promise.State.PENDING then
    local function handler(callbacks)
      for _, cb in ipairs(callbacks) do
        vim.pretty_print(pcall(cb, unpack(self._data)))
      end
    end

    if self._state == Promise.State.RESOLVED then
      vim.pretty_print "handle resolved"
      handler(self._cb_resolve)
    elseif self._state == Promise.State.REJECTED then
      vim.pretty_print "handle rejected"
      handler(self._cb_reject)
    end
  else
    error(debug.traceback "Promise was resolved in pending state")
  end
end

---@param fn function
---@return Promise
function Promise:next(fn)
  if not is_function(fn) then
    error "fn needs to be a function"
  end

  table.insert(self._cb_resolve, fn)

  return self
end

---@param fn function
---@return Promise
function Promise:catch(fn)
  if not is_function(fn) then
    error "fn needs to be a function"
  end

  table.insert(self._cb_reject, fn)

  return self
end

---@return Promise.State
function Promise:state()
  return self._state
end

function Promise:start()
  self._thread = core.scheduler():spawn(function()
    local ok, err = pcall(
      self._executor,
      Promise._resolver(self, Promise.State.RESOLVED),
      Promise._resolver(self, Promise.State.REJECTED)
    )

    if not ok then
      error(debug.traceback(err))
    else
      core.scheduler():wait_until(function()
        return self._state ~= Promise.State.PENDING
      end)

      self:_handle()
    end
  end)
end

function Promise.race() end

function Promise.all() end

return Promise
