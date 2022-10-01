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

---@module "wut.workspace"

local path = require "wut/path"
local SCM = require "wut/workspace/scm"
local Decorations = require "wut/workspace/decorations"
local Hover = require "wut/workspace/hover"

---@class Wut.Workspace.Provider.FileSystem
---@field init fun(): Wut.Workspace.Provider.FileSystem

---@class Wut.Workspace.Provider.Scm
---@field init fun(): Wut.Workspace.Provider.Scm

---@class Wut.Workspace.Provider.Decoration
---@field init fun(): Wut.Workspace.Provider.Decoration

---@class Wut.Workspace
---@field cwd fun(): string
---@field register_hook fun(name: string, handler): nil
---@field register_provider fun(name: string, provider): nil

local _private = {
  cwd = nil,
  providers = {
    ---Hold all active file system providers.
    ---@type table[]
    fs = {},

    ---Hold all active source control manager providers.
    ---@type table[]
    scm = SCM:new(),

    ---Hold all active decoration proviers. A decoration provider is responsible
    ---for handling the decoration of the active buffers open.
    ---@type Wut.Workspace.Provider.Decoration
    decoration = Decorations:new(),

    ---Hold all active hover providers.
    ---@type table[]
    hover = Hover:new(),
  },
  hooks = {
    ["OnInit"] = {},
    ["OnExit"] = {},
    ["OnUserChangedConfiguration"] = {},
    ["OnBufferOpen"] = {},
    ["OnBufferChanged"] = {},
    ["OnBufferClosed"] = {},
    ["OnFileCreated"] = {},
    ["OnFolderCreated"] = {},
    ["OnFileRenamed"] = {},
    ["OnFolderRenamed"] = {},
    ["OnFileDeleted"] = {},
    ["OnFolderDeleted"] = {},
  },
}

---@type Wut.Workspace
local M = {}

function M.setup()
  _private.cwd = path.join(vim.fn.getcwd(), vim.fn.expand "%")
end

---@param event string
---@param handler function
function M.register_hook(event, handler)
  if type(event) ~= "string" then
    error(debug.traceback "`event` needs to be a string.")
  end

  if type(handler) ~= "function" then
    error(debug.traceback "`handler` needs to be a function.")
  end

  local selected_hook = _private.hooks[event]

  if not selected_hook then
    error(debug.traceback "Invalid event name for workspace hooks.")
  end

  table.insert(selected_hook, handler)
end

---@param name string
---@param provider table
function M.register_provider(name, provider)
  if type(name) ~= "string" then
    error(debug.traceback "`name` needs to be a string.")
  end

  local selected_provider = _private.providers[name]

  if not selected_provider then
    error(debug.traceback "Invalid provider type.")
  end

  if type(provider) ~= "table" then
    error(debug.traceback "`provider` needs to be a table.")
  end

  selected_provider:register(provider)
end

---Get the current working directory
---@return string
function M.cwd()
  return _private.cwd
end

return M
