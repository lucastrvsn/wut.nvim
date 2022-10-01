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

---@module "wut.async.process"

---@class Async.Process
---@field on_data function
---@field on_error function
---@field on_end function
---@field start function

local Process = {}

local executable_exists = function(cmd)
  return vim.fn.executable(cmd) == 1
end

---@return Async.Process
---Creates a new process
function Process:new(opts)
  assert(type(opts) == "table")
  assert(type(opts.cmd) == "string")

  local process = {
    _handle = nil,
    _pid = nil,
    _stdin = vim.loop.new_pipe(false), -- FIXME: not implemented
    _stdout = vim.loop.new_pipe(false),
    _stderr = vim.loop.new_pipe(false),
    _result = "",
    _cmd = opts.cmd,
    _args = opts.args,
    _cwd = opts.cwd,
    _on_data = nil,
    _on_error = nil,
    _on_end = nil,
  }

  return setmetatable(process, {
    __index = self,
  })
end

function Process:_handle_data(_, data)
  if data then
    self._result = self._result .. data

    if type(self._on_data) == "function" then
      self._on_data(data)
    end
  end
end

function Process:_handle_error(_, data)
  if data then
    self._result = self._result .. data

    if type(self._on_error) == "function" then
      self._on_error(data)
    end
  end
end

function Process:_handle_exit(code)
  if not code then
    error()
  end

  local result = vim.split(self._result, "\n")

  if code == 0 then
    if type(self._on_end) == "function" then
      self._on_end(result)
    end
  else
    if type(self._on_error) == "function" then
      self._on_error(result)
    end
  end
end

function Process:on_end(callback)
  if type(callback) == "function" then
    self._on_end = callback
  end

  return self
end

function Process:on_error(callback)
  if type(callback) == "function" then
    self._on_error = callback
  end

  return self
end

function Process:on_data(callback)
  if type(callback) == "function" then
    self._on_data = callback
  end

  return self
end

function Process:start()
  if not executable_exists(self._cmd) then
    error(
      debug.traceback(string.format('Executable "%s" not found.', self._cmd))
    )
  end

  local spawn_options = {
    stdio = {
      self._stdin,
      self._stdout,
      self._stderr,
    },
  }

  if self._args then
    spawn_options.args = self._args
  end

  if self._cwd then
    spawn_options.cwd = self._cwd
  end

  self._handle, self._pid = vim.loop.spawn(
    self._cmd,
    spawn_options,
    function(code, signal)
      self._stdout:read_stop()
      self._stderr:read_stop()
      self._stdin:read_stop()
      self._handle:close()
      self:_handle_exit(code, signal)
    end
  )

  if not self._handle or not self._pid then
    error(debug.traceback "The process didnt started.")
  end

  vim.loop.read_start(self._stdout, function(_, data)
    self:_handle_data(_, data)
  end)

  vim.loop.read_start(self._stderr, function(_, data)
    self:_handle_error(_, data)
  end)
end

return Process
