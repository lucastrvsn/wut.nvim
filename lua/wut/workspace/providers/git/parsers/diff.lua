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

---@module "wut.workspace.git.parsers.diff"

local FILE_TYPE = {
  OLD = "FILE_OLD",
  NEW = "FILE_NEW",
}

local DIFF_TYPE = {
  ADDED = "added",
  CHANGED = "changed",
  DELETED = "deleted",
}

local create_parser = function(fn)
  return function(state, ctx)
    local new_index, updated_state = fn(ctx)
    return {
      new_state = vim.tbl_extend("force", state, updated_state),
      new_index = new_index,
    }
  end
end

local parsers = {
  ["diff"] = create_parser(function(ctx)
    return ctx.index + 1,
      {
        header = string.match(
          ctx.current_line,
          "^diff%s%-%-git%sa/(.*)%sb/(.*)$"
        ),
      }
  end),
  ["index"] = create_parser(function(ctx)
    return ctx.index + 1, {}
  end),
  ["---"] = create_parser(function(ctx)
    return ctx.index + 1, {}
  end),
  ["+++"] = create_parser(function(ctx)
    return ctx.index + 1, {}
  end),
  ["@@"] = create_parser(function(ctx)
    local chunk = {
      type = nil,
      diff = {},
      changes = 0,
      deletions = 0,
    }

    local file_a, file_b, summary =
      string.match(ctx.current_line, "^%@+%s%-([%d,]+)%s%+([%d,]+)%s%@+%s(.*)$")
    local file_a_line, file_a_count = string.match(file_a, "^(%d+),?(%d*)$")
    local file_b_line, file_b_count = string.match(file_b, "^(%d+),?(%d*)$")

    file_a_line = tonumber(file_a_line)
    file_a_count = tonumber(file_a_count) or 0
    file_b_line = tonumber(file_b_line)
    file_b_count = tonumber(file_b_count) or 0

    chunk.summary = summary
    chunk[FILE_TYPE.OLD] = {
      start_line = file_a_line,
      end_line = file_a_line + file_a_count,
    }
    chunk[FILE_TYPE.NEW] = {
      start_line = file_b_line,
      end_line = file_b_line + file_b_count,
    }

    chunk.type = DIFF_TYPE.CHANGED
    if file_a_count == 0 then
      chunk.type = DIFF_TYPE.ADDED
    elseif file_b_count == 0 then
      chunk.type = DIFF_TYPE.DELETED
    end

    local index = ctx.index + 1
    while index <= #ctx.lines do
      local diff_line = ctx.lines[index]

      if diff_line then
        local token = string.sub(diff_line, 1, 1)

        if token == "@" then
          break
        elseif token == "+" then
          chunk.changes = chunk.changes + 1
        elseif token == "-" then
          chunk.deletions = chunk.deletions + 1
        end

        table.insert(chunk.diff, diff_line)
      end

      index = index + 1
    end

    return index, {
      chunk = chunk,
    }
  end),
}

return function(output)
  local state = {
    file_a = nil,
    file_b = nil,
    header = nil,
    chunks = {},
  }

  local i = 1
  while i < #output do
    local line = output[i]
    local token = string.match(output[i], "([^%s]+)")
    local parser = parsers[token]

    if parser then
      local result = parser(state, {
        index = i,
        current_line = line,
        lines = output,
      })

      if result then
        state = result.new_state
        i = result.new_index
      end
    else
      -- Just in case we end up infinite loop for some reason
      i = i + 1
    end
  end

  return state
end
