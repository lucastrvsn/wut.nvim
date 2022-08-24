local M = {}

M.join = function(...)
  return table.concat(vim.tbl_flatten { ... }, "/")
end

M.format = function(opts)
  --
end

M.normalize = function()
  --
end

M.ext = function(path)
  --
end

M.dirname = function(path)
  local strip_dir_pat = "/([^/]+)$"
  local strip_sep_pat = "/$"

  if not path or #path == 0 then
    return
  end

  local result = path:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")

  if #result == 0 then
    return "/"
  end

  return result
end

M.is_root_directory = function(path)
  return path == "/"
end

M.is_absolute = function()
  --
end

M.is_directory = function(path)
  return M.exists(path) == "directory"
end

M.is_file = function(path)
  return M.exists(path) == "file"
end

M.exists = function(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type or false
end

M.traverse_parents = function(path, cb)
  local real_path = vim.loop.fs_realpath(path)
  local dir = M.dirname(real_path)

  if not dir then
    return
  end

  if cb(dir, real_path) then
    return dir, real_path
  end

  if M.is_root_directory(dir) then
    return false
  end
end

M.parents = function(path)
  local function it(_, current_path)
    if current_path and not M.is_root_directory(current_path) then
      current_path = M.dirname(current_path)
    else
      return
    end

    if current_path and vim.loop.fs_realpath(current_path) then
      return current_path, path
    else
      return
    end
  end

  return it, path, path
end

M.find_ancestors = function(current_path, fn)
  if fn(current_path) then
    return current_path
  end

  for path in M.parents(current_path) do
    if fn(path) then
      return path
    end
  end
end

return M
