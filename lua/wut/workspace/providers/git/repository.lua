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

---@module "wut.workspace.git.repository"

local Promise = require "wut/core/promise"
local Process = require "wut/async/process"

---@class Git.Repository.BlameLine
---@field hash string
---@field author_name string
---@field author_mail string
---@field author_time string
---@field author_timezone string
---@field committer_name string
---@field committer_mail string
---@field committer_time string
---@field committer_timezone string
---@field summary string
---@field filename string

local Repository = {}

---Create a new Repository instance for given directory.
function Repository:new(bin_path, root_path)
  local repository = {
    ["@@type"] = "GitRepository",
    _config = {},
  }

  if not root_path then
    error(debug.traceback "Need to provide the git root directory.")
  end

  if not bin_path then
    error(debug.traceback "Need to provide the git executable path.")
  end

  repository._bin = bin_path
  repository._root = root_path

  return setmetatable(repository, {
    __index = self,
  })
end

---@return boolean
function Repository:is_repository()
  return self._root ~= nil
end

---@param args string[]
---@return Async.Process
function Repository:exec(args)
  assert(type(args) == "table")

  return Process:new {
    cmd = self._bin,
    cwd = self._root,
    args = args,
  }
end

---Load all the config values from `git`.
---@return Promise
function Repository:load_config()
  return Promise:new(function(resolve, reject)
    self
      :exec({
        "config",
        "--list",
      })
      :on_end(resolve)
      :on_error(reject)
      :start()
  end)
end

---Get the value from the `git` config.
---@param key string
---@return Promise<string>
function Repository:config(key)
  assert(type(key) == "string")

  return Promise:new(function(resolve, reject)
    self
      :exec({
        "config",
        "--get",
        key,
      })
      :on_end(function(data)
        self._config[key] = data
        resolve(data)
      end)
      :on_error(reject)
      :start()
  end)
end

---@param file string
---@return Promise
function Repository:diff(file)
  assert(type(file) == "string")

  return Promise:new(function(resolve, reject)
    self
      :exec({
        "diff",
        "--unified=0",
        "--",
        file,
      })
      :on_end(function(data)
        resolve(require "wut/git/workspace/parsers/diff"(data))
      end)
      :on_error(reject)
      :start()
  end)
end

---@return Promise
function Repository:diff_files()
  return Promise:new(function(resolve, reject)
    self
      :exec({
        "diff",
        "--name-status",
        "--diff-filter=ADMR",
      })
      :on_end(resolve)
      :on_error(reject)
      :start()
  end)
end

---@param file string
---@param text string
---@return Promise
function Repository:diff_from_text(file, text)
  assert(type(file) == "string")
  assert(type(text) == "string")

  return Promise:new(function(resolve)
    local temp_file = vim.fn.tempname()
    resolve(temp_file)
  end)
end

---Return all files tracked by `git`.
---@return Promise
function Repository:files()
  return Promise:new(function(resolve, reject)
    self
      :exec({
        "ls-files",
      })
      :on_end(resolve)
      :on_error(reject)
      :start()
  end)
end

---@return Promise
function Repository:blame() end

---@param file string
---@param line_number number | string
---@return Promise
function Repository:blame_line(file, line_number)
  assert(type(file) == "string")
  assert(type(line_number) == "string" or type(line_number) == "number")

  return Promise:new(function(resolve, reject)
    self
      :exec({
        "blame",
        "-L",
        string.format("%s,+1", line_number),
        "--line-porcelain",
        "--",
        file,
      })
      :on_end(function(output)
        resolve(require "wut/workspace/git/parsers/blame"(output))
      end)
      :on_error(reject)
      :start()
  end)
end

---@return Promise
function Repository:status()
  return Promise:new(function(resolve, reject)
    self
      :exec({
        "status",
        "--porcelain=v1",
      })
      :on_end(resolve)
      :on_error(reject)
      :start()
  end)
end

---@return Promise
function Repository:checkout() end

return Repository
