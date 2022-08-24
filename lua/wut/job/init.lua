local Job = {}

function Job:new(opts)
  assert(type(opts) == "table")
  assert(type(opts.cmd) == "string")

  local job = {
    _handle = nil,
    _pid = nil,
    _state = "CREATED",
    _stdin = vim.loop.new_pipe(false),
    _stdout = vim.loop.new_pipe(false),
    _stderr = vim.loop.new_pipe(false),
    _result = "",
    _cmd = opts.cmd,
    _args = opts.args,
    _cwd = opts.cwd,
    _cb_on_stdout = opts.on_stdout,
    _cb_on_stderr = opts.on_stderr,
    _cb_on_exit = opts.on_exit,
  }

  return setmetatable(job, {
    __index = self,
  })
end

function Job:start()
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

  self._handle, self._pid = vim.loop.spawn(self._cmd, spawn_options, function()
    self._stdout:read_stop()
    self._stderr:read_stop()
    self._stdin:read_stop()
    self._handle:close()

    if type(self._cb_on_exit) == "function" then
      self._cb_on_exit(vim.split(self._result, "\n"))
    end
  end)

  if not self._handle or not self._pid then
    -- error
  end

  vim.loop.read_start(self._stdout, function(_, data)
    if data then
      self._result = self._result .. data

      if type(self._cb_on_stdout) == "function" then
        self._cb_on_stdout(data)
      end
    end
  end)

  vim.loop.read_start(self._stderr, function(_, data)
    if data then
      self._result = self._result .. data

      if type(self._cb_on_stderr) == "function" then
        self._cb_on_stderr(data)
      end
    end
  end)
end

return Job
