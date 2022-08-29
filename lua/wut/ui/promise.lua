local is_function = require("wut/utils/functions").is_function

local Promise = {}

local State = {
  PENDING = "pending",
  RESOLVED = "resolved",
  REJECTED = "rejected",
}

function Promise:new(fn)
  local promise = {
    ["@@type"] = "Promise",
    _coroutine = nil,
    _state = nil,
    _on_resolve = {},
    _on_reject = {},
    _on_done = {},
  }

  if not is_function(fn) then
    error "not a function"
  end

  promise._state = State.PENDING

  promise._coroutine = coroutine.create(function(...)
    local _args = { ... }
    coroutine.yield(function()
      fn(unpack(_args))
    end)
  end)

  return setmetatable(promise, {
    __index = self,
  })
end

function Promise:_runner()
  local _resolve = function(...)
    return self:_resolve(...)
  end

  local _reject = function(...)
    return self:_reject(...)
  end

  local ok, data = coroutine.resume(self._coroutine, _resolve, _reject)

  if not ok then
    vim.pretty_print "error?"
    error(debug.traceback(self._coroutine, data))
  end

  if coroutine.status(self._coroutine) ~= "dead" then
    vim.pretty_print "init?"
    data(self._runner)
  end
end

function Promise:_resolve(result)
  self._state = State.RESOLVED

  for _, cb in ipairs(self._on_resolve) do
    cb(result)
  end
end

function Promise:_reject(err)
  self._state = State.REJECTED

  for _, cb in ipairs(self._on_reject) do
    cb(err)
  end
end

function Promise:_finally()
  for _, cb in ipairs(self._on_done) do
    cb()
  end
end

function Promise:next(fn)
  if is_function(fn) then
    table.insert(self._on_resolve, fn)
  end

  return self
end

function Promise:catch(fn)
  if is_function(fn) then
    table.insert(self._on_reject, fn)
  end

  return self
end

function Promise:done(fn)
  if is_function(fn) then
    table.insert(self._on_done, fn)
  end

  return self
end

function Promise:start()
  self:_runner()
end

function Promise:cancel() end

function Promise.all(promises) end

function Promise.race(promises) end

return Promise
