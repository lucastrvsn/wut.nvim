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

---@module "wut.workspace.folder.providers.fd"

local Process = require "wut/async/process"
local Promise = require "wut/core/promise"

local M = {}

M.all = function(opts)
  local cwd = opts.cwd
  local ignore_patterns = opts.ignore_patterns
  local args = { "." }

  if ignore_patterns then
    for _, pattern in ipairs(ignore_patterns) do
      table.insert(args, string.format('-E "%s"', pattern))
    end
  end

  local process = Process:new {
    cmd = "fd",
    cwd = cwd,
    args = args,
  }

  return Promise:new(function(resolve, reject)
    vim.schedule(function()
      process
        :on_end(function(data)
          resolve(data)
        end)
        :on_error(function(err)
          reject(err)
        end)
        :start()
    end)
  end)
end

M.search = function() end

return M
