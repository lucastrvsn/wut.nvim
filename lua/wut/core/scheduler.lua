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
---@see https://mode13h.io/coroutines-scheduler-in-lua/

---@module "wut.core.scheduler"

local Thread = require "wut/core/thread"

---@class SchedulerConstructor

---@class Scheduler
---@field ["@@type"] "Scheduler"
---@field _thread thread The main scheduler coroutine thread
---@field _pool table<thread, Thread.Params> All current running threads
---@field _ready table<thread, Thread.Params> Threads with "ready" state
---@field _thread_count number The number of threads running
---@field new fun(): Scheduler
---@field init fun()
---@field yield function
---@field wait function
---@field wait_until function
---@field signal function
---@field spawn function
---@field tick function
---@field dump function

local Scheduler = {}

---@return Scheduler
function Scheduler:new()
  local scheduler = {
    ["@@type"] = "Scheduler",
    private = {},
    _thread = nil,
    _thread_count = 0,
    _pool = {},
    _ready = {},
  }

  return setmetatable(scheduler, {
    __index = self,
  })
end

---Start the coroutine which will run the main loop of the scheduler
function Scheduler:init()
  self._thread = coroutine.create(function()
    while true do
      self:tick()

      if self._thread_count == 0 then
        -- If we don't have any thread to run, yield itself until
        -- we've other thread to be run
        coroutine.yield()
      else
        vim.schedule(function()
          coroutine.resume(self._thread)
        end)
        coroutine.yield()
      end
    end
  end)
end

---@async
---@param ... any
---Yield the current thread
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
---Suspend the current thread until the `fn` function return true
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

---Awake the scheduler if needed when we're in the `suspended` state
function Scheduler:awake()
  if coroutine.status(self._thread) == "suspended" then
    local ok, result = coroutine.resume(self._thread)

    if not ok then
      error(debug.traceback(result))
    end
  end
end

---@class Scheduler.Spawn.Options
---@field priority? number

---@param fn function | thread
---@param opts Thread.Create.Options
---@param ... any
---@return string id The new thread id
function Scheduler:spawn(fn, opts, ...)
  local thread, params = Thread.create(fn, opts, ...)

  self._pool[thread] = params
  self._thread_count = self._thread_count + 1

  table.sort(self._pool, function(a, b)
    return a.priority > b.priority
  end)

  self:awake()

  return params.id
end

function Scheduler:tick()
  for thread, params in pairs(self._pool) do
    local status = coroutine.status(thread)

    if status == "dead" then
      self._pool[thread] = nil
      self._thread_count = self._thread_count - 1
    elseif status == "suspended" then
      if params.status == Thread.State.ERROR then
        -- TODO: handle this error state
        vim.pretty_print "ERROR"
      elseif params.status == Thread.State.CHECKING then
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

  -- Run all threads in `ready` state
  while #self._ready > 0 do
    local thread = table.remove(self._ready)
    local params = self._pool[thread]
    params.status = Thread.State.RUNNING

    local ok, data = coroutine.resume(thread, unpack(params.args))

    if not ok then
      params.status = Thread.State.ERROR
      error(debug.traceback(data))
    end
    -- elseif data ~= nil then
    --   self._pool[thread].status = Thread.State.READY
    --   self._pool[thread].args = { data }
    -- end
  end
end

function Scheduler:dump()
  for thread, params in pairs(self._pool) do
    print(
      string.format(
        "[%s] priority:%d status:%d coroutine:%s",
        thread,
        params.priority,
        params.status,
        coroutine.status(thread)
      )
    )
  end
end

return Scheduler
