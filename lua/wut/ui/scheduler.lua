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

---@module "ui.scheduler"

State = {
  READY = 1,
  RUNNING = 2,
  WAITING = 3,
  SLEEPING = 4,
  CHECKING = 5,
}

local Scheduler = {}

function Scheduler:new()
  local scheduler = {
    _pool = {},
  }

  return setmetatable(scheduler, {
    __index = self,
  })
end

---@param ... any
---Yield the scheduler
function Scheduler:yield(...)
  local thread = coroutine.running()

  print "asldkalsdk"

  local params = self._pool[thread]
  params.status = State.READY
  params.value = nil

  return coroutine.yield(...)
end

function Scheduler:sleep() end

function Scheduler:check(predicate, ...)
  local thread = coroutine.running()

  local params = self._pool[thread]
  params.status = State.CHECKING
  params.value = predicate

  return coroutine.yield(...)
end

function Scheduler:wait(id, ...)
  local thread = coroutine.running()

  local params = self._pool[thread]
  params.status = State.WAITING
  params.value = id

  return coroutine.yield(...)
end

function Scheduler:signal(id)
  for _, params in pairs(self._pool) do
    if params.status == State.WAITING then
      if params.value == id then
        params.status = State.READY
        params.value = nil
      end
    end
  end
end

function Scheduler:spawn(procedure, priority, ...)
  local thread = coroutine.create(procedure)

  self._pool[thread] = {
    priority = priority or 0,
    args = { ... },
    status = State.READY,
    value = nil,
  }

  table.sort(self._pool, function(a, b)
    return a.priority > b.priority
  end)
end

function Scheduler:pulse(ticks)
  local ready_to_resume = {}

  for thread, params in pairs(self._pool) do
    local status = coroutine.status(thread)

    if status == "dead" then
      self._pool[thread] = nil
    elseif status == "suspended" then
      if params.status == State.SLEEPING then
        params.value = params.value - ticks
        if params.value <= 0 then
          params.status = State.READY
          params.value = nil
        end
      elseif params.status == State.CHECKING then
        if params.value() then
          params.status = State.READY
          params.value = nil
        end
      end

      if params.status == State.READY then
        table.insert(ready_to_resume, thread)
      end
    end
  end

  for _, thread in ipairs(ready_to_resume) do
    local params = self._pool[thread]
    params.status = State.RUNNING
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
