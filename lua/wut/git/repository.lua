local Job = require "wut/job"

local Repository = {}

function Repository:new()
  local repository = {
    _bin = nil,
    _root = nil,
    _config = {},
    _files = {},
  }

  repository._bin = require("wut/git/helpers").get_git_executable()
  repository._root =
    require("wut/git/helpers").get_git_root(vim.fn.expand "%:p")

  return setmetatable(repository, {
    __index = self,
  })
end

function Repository:is_repository()
  return self._root ~= nil
end

function Repository:exec(args, callback)
  assert(type(args) == "table")

  Job:new({
    cmd = self._bin,
    cwd = self._root,
    args = args,
    on_exit = callback,
  }):start()
end

function Repository:load_config(callback)
  self:exec({
    "config",
    "--list",
  }, function(data)
    if type(callback) == "function" then
      callback(data)
    end
  end)
end

function Repository:config(key, callback)
  assert(type(key) == "string")

  self:exec({
    "config",
    "--get",
    key,
  }, function(data)
    local config = data
    self._config[key] = config

    if type(callback) == "function" then
      callback(config)
    end
  end)
end

-- => Chunk {
--   header = nil,
-- }
function Repository:diff(file)
  assert(type(file) == "string")

  self:exec({
    "diff",
    "--unified=0",
    "--",
    file,
  }, function(data)
    require "wut/git/parsers/diff"(data)
  end)
end

function Repository:diff_files()
  self:exec({
    "diff",
    "--name-status",
    "--diff-filter=ADMR",
  }, function(data)
    vim.pretty_print(data)
  end)
end

function Repository:diff_from_text(file, text)
  assert(type(file) == "string")
  assert(type(text) == "string")

  vim.pretty_print(vim.fn.tempname())
end

function Repository:files()
  self:exec({
    "ls-files",
  }, function(data)
    vim.pretty_print(data)
  end)
end

function Repository:blame(file)
  assert(type(file) == "string")
end

-- git blame -L <start_line>,<end_line> <file>
-- => {
--   hash,
--   author_name,
--   author_mail,
--   author_time,
--   author_timezone,
--   committer_name,
--   committer_mail,
--   committer_time,
--   committer_timezone,
--   summary,
--   filename,
-- }
function Repository:blame_line(file, line_number)
  assert(type(file) == "string")
  assert(type(line_number) == "string" or type(line_number) == "number")

  self:exec({
    "blame",
    "-L",
    string.format("%s,+1", line_number),
    "--line-porcelain",
    "--",
    file,
  }, function(data)
    vim.pretty_print(data)
  end)
end

function Repository:status()
  self:exec({
    "status",
    "--porcelain=v1",
  }, function(data)
    vim.pretty_print(data)
  end)
end

function Repository:checkout()
  --
end

return Repository
