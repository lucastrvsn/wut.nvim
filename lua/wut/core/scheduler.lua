--[[
Copyright (c) 2015 Marco Lizza (marco.lizza@gmail.com)
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

---The original implementation of this source code can be found at:
---@source https://mode13h.io/coroutines-scheduler-in-lua/

---@module "wut.core.scheduler"

local Thread = require "wut/core/thread"
local types = require "wut/core/types"

---@class Scheduler
---@field ["@@type"] "Scheduler"
---@field _pool table<thread, Thread.Params> All current running threads
---@field _ready table<thread, Thread.Params> Thread with "ready" state

---@type Scheduler
local Scheduler = {}

---@enum Scheduler.State
Scheduler.State = {
  IDLE = 1,
  RUNNING = 2,
  DEAD = 3,
}

---@return Scheduler
function Scheduler:new()
  ---@type Scheduler
  local scheduler = {
    ["@@type"] = types.SCHEDULER,
    _state = Scheduler.State.IDLE,
    _pool = {},
    _ready = {},
  }

  return setmetatable(scheduler, {
    __index = self,
  })
end

---@async
---@param ... any
---Yield the scheduler
function Scheduler:yield(...)
  local thread = coroutine.running()

  local params = self._pool[thread]
  params.status = Thread.State.READY
  params.value = nil

  return coroutine.yield(...)
end

---@async
---@param id string
---@param ... any
---@return thread
function Scheduler:wait(id, ...)
  local thread = coroutine.running()

  local params = self._pool[thread]
  params.status = Thread.State.WAITING
  params.value = id

  return coroutine.yield(...)
end

---@async
---@param fn fun(): boolean
---@param ... any
---@return thread
---Suspend the current thread until the "fn" function return true
function Scheduler:wait_until(fn, ...)
  local thread = coroutine.running()

  local params = self._pool[thread]
  params.status = Thread.State.CHECKING
  params.value = fn

  return coroutine.yield(...)
end

---@param id string
function Scheduler:signal(id)
  for _, params in pairs(self._pool) do
    if params.status == Thread.State.WAITING then
      if params.value == id then
        params.status = Thread.State.READY
        params.value = nil
      end
    end
  end
end

---@class Scheduler.Spawn.Options
---@field fn function
---@field priority? number

---@param opts Thread.Create.Options
---@param ... any
---@return string id The new thread id
function Scheduler:spawn(opts, ...)
  local thread, params = Thread.create(opts, ...)

  self._pool[thread] = params

  table.sort(self._pool, function(a, b)
    return a.priority > b.priority
  end)

  return params.id
end

function Scheduler:tick()
  self._ready = {}

  for thread, params in pairs(self._pool) do
    local status = coroutine.status(thread)

    if status == "dead" then
      self._pool[thread] = nil
    elseif status == "suspended" then
      if params.status == Thread.State.CHECKING then
        if params.value() then
          params.status = Thread.State.READY
          params.value = nil
        end
      end

      if params.status == Thread.State.READY then
        table.insert(self._ready, thread)
      end
    end
  end

  for _, thread in ipairs(self._ready) do
    local params = self._pool[thread]
    params.status = Thread.State.RUNNING
    coroutine.resume(thread, unpack(params.args))
  end
end

function Scheduler:dump()
  for thread, params in pairs(self._pool) do
    print(thread)
    print(
      string.format(
        "  %d %d %s",
        params.priority,
        params.status,
        coroutine.status(thread)
      )
    )
  end
end

return Scheduler
