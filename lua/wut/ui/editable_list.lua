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

---@module "wut.ui.views.editable_list"

---@class EditableList.Entry
---@field index number
---@field key string
---@field content string
---@field data table

---@class EditableList.Extmark
---@field id number
---@field row number
---@field col number
---@field entry EditableList.Entry
---@field is_dirty boolean
---@field is_deleted boolean

local EditableList = {}

---@class EditableList.New.Options
---@field namespace number

---@param opts EditableList.New.Options
function EditableList:new(opts)
  local editable_list = {
    _buffer = vim.api.nvim_create_buf(false, true),
    _namespace = opts.namespace or 0,
    _entry_count = -1,
    _entries = {},
    _marks = {},
  }

  return setmetatable(editable_list, {
    __index = self,
  })
end

---@param firstline number
---@param old_lastline number
---@param new_lastline number
function EditableList:_handle_on_lines(firstline, old_lastline, new_lastline)
  vim.pretty_print(firstline, old_lastline, new_lastline)

  if old_lastline > new_lastline then
    vim.pretty_print "DELETING"

    for _, mark in pairs(self._marks) do
      if mark.row >= firstline and mark.row < old_lastline then
        mark.is_deleted = true
      end
    end

    -- Recalculate line_number for extmarks
    local deleted_count = old_lastline - new_lastline

    for _, mark in pairs(self._marks) do
      if mark.row - deleted_count >= new_lastline then
        mark.row = mark.row - deleted_count
        mark.is_dirty = true
      end
    end
  elseif new_lastline > old_lastline then
    vim.pretty_print "INSERTING"
    local offset = new_lastline - old_lastline

    local line_number = firstline
    if firstline ~= old_lastline then
      line_number = old_lastline
    end

    -- Recalculate line_number for all affected marks
    for _, mark in pairs(self._marks) do
      if mark.row >= line_number then
        mark.row = mark.row + offset
        mark.is_dirty = true
      end
    end

    self:create_extmark {
      position = { line_number, 0 },
      entry = {
        key = "new",
        content = "new",
      },
    }
  else
    vim.pretty_print "RENAMING"
  end
end

function EditableList:on_open()
  local current_buf_attach_tick = nil

  vim.api.nvim_buf_attach(self._buffer, false, {
    on_lines = function(_, _, changedtick, ...)
      if current_buf_attach_tick ~= changedtick then
        current_buf_attach_tick = changedtick
        self:_handle_on_lines(...)
      end
    end,
  })

  vim.api.nvim_set_decoration_provider(self._namespace, {
    on_win = function(_, _, buffer)
      if self._buffer == buffer then
        for _, mark in pairs(self._marks) do
          local status, message = pcall(self.update_extmark, self, mark)

          if not status then
            error(debug.traceback(message))
          end
        end
      end
    end,
  })

  vim.keymap.set("n", "<CR>", function()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local pos = { cursor - 1, 0 }
    local m =
      vim.api.nvim_buf_get_extmarks(self._buffer, self._namespace, pos, pos, {})
    vim.pretty_print(m)
  end, {
    buffer = self._buffer,
  })
end

function EditableList:on_close() end

---@param opts table
function EditableList:create_entry(opts)
  self._entry_count = self._entry_count + 1

  local new_entry = {
    index = self._entry_count,
    key = opts.key,
    content = opts.content,
    data = opts,
  }

  vim.api.nvim_buf_set_lines(
    self._buffer,
    self._entry_count,
    self._entry_count,
    false,
    { new_entry.key .. new_entry.content }
  )

  self._entries[new_entry.key] = new_entry

  self:create_extmark {
    position = { new_entry.index, 0 },
    entry = new_entry,
  }

  return new_entry
end

---@class EditableList.CreateExtmark.Options
---@field position { row: number, col: number }
---@field entry EditableList.Entry

---@param opts EditableList.CreateExtmark.Options
---@return EditableList.Extmark
function EditableList:create_extmark(opts)
  local row = opts.position[1] or 0
  local col = opts.position[2] or -1
  local mark = {
    id = nil,
    row = row,
    col = col,
    entry = opts.entry,
    is_dirty = true,
    is_deleted = false,
  }
  mark.id = vim.api.nvim_buf_set_extmark(
    self._buffer,
    self._namespace,
    mark.row,
    mark.col,
    {
      right_gravity = false,
      virt_text = {
        { mark.row .. " " .. mark.entry.key, "@comment" },
      },
      virt_text_pos = "right_align",
    }
  )

  self._marks[mark.id] = mark

  return mark
end

---@param mark EditableList.Extmark
function EditableList:update_extmark(mark)
  if mark.is_deleted then
    vim.api.nvim_buf_del_extmark(self._buffer, self._namespace, mark.id)
  elseif mark.is_dirty then
    vim.api.nvim_buf_set_extmark(
      self._buffer,
      self._namespace,
      mark.row,
      mark.col,
      {
        id = mark.id,
        right_gravity = false,
        virt_text = {
          { mark.row .. " " .. mark.entry.key, "@comment" },
        },
        virt_text_pos = "right_align",
      }
    )

    mark.is_dirty = false
  end
end

function EditableList:set_entries(entries)
  for _, entry in pairs(entries) do
    self:create_entry(entry)
  end
end

function EditableList:render()
  return self._buffer
end

return EditableList
