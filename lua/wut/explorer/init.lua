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

---@module "wut.explorer"

local path = require "wut/path"
local hl = require "wut/highlight"
local Window = require "wut/ui/window"
local EditableList = require "wut/ui/editable_list"

local function create_operation(type, filetype, old_path, new_path)
  local operation = {
    type = type,
    filetype = filetype,
  }

  if old_path then
    operation.old = {
      path = old_path,
    }
  end

  if new_path then
    operation.new = {
      path = new_path,
    }
  end

  return operation
end

local M = {
  _folder = {},
  _namespace = vim.api.nvim_create_namespace "aaaa",
  _operations = {},
  _window = nil,
  _view = nil,
}

function M.setup()
  M._window = Window:new({
    name = "@wut.explorer",
    window = {
      relative = "editor",
      width = 50,
      height = 14,
      row = 10,
      col = 10,
      style = "minimal",
      border = "none",
    },
    options = {
      number = true,
      conceallevel = 2,
      concealcursor = "nc",
    },
  }):attach(function(config)
    M._view = EditableList:new {
      namespace = config.namespace,
    }

    -- Creates the highlight groups used by this plugin
    hl.create {
      name = "explorer.entry.directory",
      namespace = config.namespace,
      style = {
        link = "@label",
      },
    }
    hl.create {
      name = "explorer.entry.file",
      namespace = config.namespace,
      style = {
        link = "@text",
      },
    }

    return M._view
  end)

  vim.keymap.set("n", "-", function()
    M.open()
  end)
end

function M.open()
  local cwd = vim.fn.getcwd()
  local entries = {}

  local function create_entry(entry, children)
    table.insert(entries, {
      id = entry.id,
      index = entry.index,
      filename = entry.filename,
      filetype = entry.filetype,
      filepath = entry.filepath,
      children = children or nil,
    })
  end

  for name, type in path.dir(cwd) do
    local filepath = path.join(cwd, name)
    local id = vim.fn.id(filepath)

    local highlight = nil
    if type == "file" then
      highlight = hl.get "explorer.entry.file"
    elseif type == "directory" then
      highlight = hl.get "explorer.entry.directory"
    end

    create_entry {
      id = id,
      filename = name,
      filetype = type,
      filepath = filepath,
      style = {
        hl_filename = highlight,
      },
    }
  end

  for _, entry in ipairs(entries) do
    M._view:set_entries {
      {
        key = entry.id,
        content = entry.filename,
      },
    }
  end

  M._window:open { should_focus = true }
end

function M.show()
  -- vim.fn.matchadd("Conceal", "^0x[[:xdigit:]]\\+\\s", 10, -1, {
  --   conceal = "",
  -- })
  -- vim.api.nvim_win_set_option(win, "conceallevel", 3)
  -- vim.api.nvim_win_set_option(win, "concealcursor", "nc")
  -- vim.api.nvim_win_set_hl_ns(win, M._namespace)
end

---Table of operations done in the current state
---@param firstline number
---@param lastline number
---@return table
function M.diff(firstline, lastline)
  local operations = {}
  --FIXME: the value `80` needs to be changed to always map to the first
  --occourence of the change and the last occourence of the change in the buffer.
  --This is necessary to get the context for the diff, but we can improve this to
  --just providing the necessary context.
  --Need a way to set values when we make changes, and save the top most line count
  --of a single change and the last most line count of a single change.
  local current_lines =
    vim.api.nvim_buf_get_lines(M._hidden_buffer, 0, -1, false)
  local changed_lines = vim.api.nvim_buf_get_lines(M._buffer, 0, -1, false)

  local diff = vim.split(
    vim.diff(
      table.concat(current_lines, "\n") .. "\n",
      table.concat(changed_lines, "\n") .. "\n",
      {
        algorithm = "myers",
        interhunkctxlen = 4,
        ignore_blank_lines = true,
        ignore_whitespace_change_at_eol = true,
      }
    ),
    "\n"
  )

  vim.pretty_print(diff)

  local index = 1
  while #diff > index do
    local line = diff[index]

    if string.match(line, "^%@%@") then
      local file_a, file_b =
        string.match(line, "^%@+%s%-([%d,]+)%s%+([%d,]+)%s%@+$")
      local file_a_line, file_a_count = string.match(file_a, "^(%d+),?(%d*)$")
      local file_b_line, file_b_count = string.match(file_b, "^(%d+),?(%d*)$")

      file_a_line = tonumber(file_a_line)
      file_a_count = tonumber(file_a_count) or nil
      file_b_line = tonumber(file_b_line)
      file_b_count = tonumber(file_b_count) or nil

      index = index + 1

      if file_a_line ~= file_b_line and not file_b_count then
        index = index + 1
        local hunk_line = diff[index]
        -- add
        vim.pretty_print "need to create the file"
      elseif file_a_line ~= file_b_line and not file_a_count then
        vim.pretty_print "need to delete the file"
      else
        vim.pretty_print "need to rename the file"

        while true do
          local hunk_file = diff[index]
          local start_with = string.sub(hunk_file, 1, 1)

          if start_with == "@" then
            break
          end

          index = index + 1
        end
      end

      vim.pretty_print(file_a_line, file_a_count, file_b_line, file_b_count)

      index = index + 1
    else
      index = index + 1
    end
  end

  return {}
end

---@param filename string
---@return table | nil
function M.find(filename)
  for _, entry in ipairs(M._state) do
    if entry.filename == filename then
      return entry
    end
  end

  return nil
end

---@param buffer number
---@param changedtick number | nil
---@param firstline number
---@param old_lastline number
---@param new_lastline number
---@return table The changes made in the virtual directory
function M.process_changes(
  buffer,
  changedtick,
  firstline,
  old_lastline,
  new_lastline
)
  vim.pretty_print(buffer, changedtick, firstline, old_lastline, new_lastline)
  local operations = {}

  if #current_lines > #changed_lines then
    -- DELETED => current_lines
    for _, line in ipairs(current_lines) do
      local entry = M.find(line)

      if entry then
        table.insert(
          operations,
          create_operation("rm", entry.filetype, entry.path, nil)
        )
      end
    end
  elseif #current_lines < #changed_lines then
    -- ADDED => changed_lines
    for _, line in ipairs(changed_lines) do
      local filetype = "file"

      -- check if its a directory
      if string.match(vim.trim(line), "^(.*)/$") then
        filetype = "directory"
      end

      table.insert(
        operations,
        create_operation("rm", filetype, "/test/" .. line, nil)
      )
    end
  else
    -- RENAMED
    vim.pretty_print "renamed"
  end

  -- vim.pretty_print(operations)

  return {}
end

---@param operations table
---@return table The merged operations table
function M.merge_operations(operations) end

function M.commit()
  vim.api.nvim_buf_set_option(M._hidden_buffer, "modifiable", true)
  vim.api.nvim_buf_set_lines(M._hidden_buffer, 0, -1, false, {})
  vim.api.nvim_buf_set_option(M._hidden_buffer, "modifiable", false)
end

function M.save() end

return M
