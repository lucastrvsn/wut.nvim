local path = require "wut/utils/path"

local M = {}

M.get_git_root = function(current_path)
  assert(type(current_path) == "string")

  local git_directory = path.find_ancestors(current_path, function(p)
    local git_path = path.join(p, ".git")

    if path.is_directory(git_path) or path.is_file(git_path) then
      return true
    end
  end)

  if not git_directory then
    -- .git doesnt exists
    -- TODO: error?
  end

  return git_directory
end

M.get_git_executable = function()
  local executable = vim.fn.executable "git"

  if executable ~= 1 then
    -- git doesnt exists
    -- TODO: error?
  end

  return vim.fn.exepath "git"
end

return M
