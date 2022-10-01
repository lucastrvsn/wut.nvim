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

---@module "wut.path"

local M = {}

---@param file string
---@return string
function M.basename(file)
  return vim.fs.basename(file)
end

---Get the absolute path of the given relative path
---@param path string
---@return string
function M.abs(path)
  -- TODO
end

---@param file string
---@return string | nil
function M.dirname(file)
  return vim.fs.dirname(file)
end

---@param path string
---@return string
function M.extname(path)
  -- TODO
end

---@param path string
---@return string[]
function M.split(path)
  -- TODO
end

---@param path string
---@return string | boolean
function M.exists(path)
  local stat = vim.loop.fs_stat(path)
  return (stat and stat.type) or false
end

---@param path string
---@return boolean
function M.is_absolute(path)
  -- TODO
end

---@param path string
---@return boolean
function M.is_directory(path)
  return (M.exists(path) == "directory") or false
end

---@param path string
---@return boolean
function M.is_file(path)
  return (M.exists(path) == "file") or false
end

---@param ... string[]
---@return string
function M.join(...)
  return table.concat(vim.tbl_flatten { ... }, "/")
end

---@param path string
---@return string
function M.normalize(path)
  return vim.fs.normalize(path)
end

---@param path string
---@return Iterator
function M.dir(path)
  return vim.fs.dir(path)
end

---Search a given pattern in all ancestors of given path. Return `nil` if not found.
---@param path string
---@param ... string
---@return string | nil
function M.find_ancestors(path, ...)
  if type(path) ~= "string" then
    error(debug.traceback())
  end

  local pattern = { ... }

  if type(pattern) ~= "table" then
    error(debug.traceback())
  end

  for current_path in vim.fs.parents(M.normalize(path)) do
    for _, item in ipairs(pattern) do
      local filepath = M.join(current_path, item)

      if M.exists(filepath) then
        return current_path
      end
    end
  end

  return nil
end

return M
