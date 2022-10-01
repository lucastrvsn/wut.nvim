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

---@module "wut.workspace.git"

local workspace = require "wut/workspace"
local Repository = require "wut/workspace/git/repository"
local path = require "wut/path"

---@type Wut.Workspace.Provider.Scm
local GitProvider = {}

function GitProvider:new()
  local git = {
    _repository = nil,
  }

  local root_path = path.find_ancestors(workspace._cwd, ".git")
  local bin_path = vim.fn.exepath "git"

  git._repository = Repository:new(bin_path, root_path)

  if not git._repository:is_repository() then
    vim.notify "Not in a git repository, disabling git provider."
    return nil
  end

  -- Set the git root as the current directory of neovim
  -- TODO: option to disable this?
  vim.schedule(function()
    vim.api.nvim_set_current_dir(root_path)
    vim.notify(string.format("Setting you CWD to: %s", root_path))
  end)

  workspace.register_provider("scm", {})

  workspace.register_provider("decoration", {
    on_line = function(filepath, line_number)
      git._repository
        :blame_line(filepath, line_number)
        :next(function(data)
          vim.pretty_print("data", data)
        end)
        :catch(function(err)
          vim.pretty_print("err", err)
        end)
        :start()
    end,
  })

  return setmetatable(git, {
    __index = self,
  })
end

return GitProvider
