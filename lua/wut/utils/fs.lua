local M = {}

M.exists = function(path)
  return vim.loop.fs_stat(path) and true or false
end

M.file_read = function(file, callback) end

M.file_read_sync = function(file) end

M.readdir = function(root)
  assert(type(root) == "string")

  local handle = vim.loop.fs_scandir(root)
  local nodes = {}

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)

    if not name then
      break
    end

    table.insert(nodes, { name, type })
  end

  return nodes
end

return M
