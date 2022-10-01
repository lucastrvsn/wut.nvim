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

---@module "wut.workspace.git.parsers.blame"

---@class Wut.Workspace.Git.Blame.Author
---@field name string
---@field email string
---@field time string
---@field timezone string

---@class Wut.Workspace.Git.Blame.Committer
---@field name string
---@field email string
---@field time string
---@field timezone string

---@class Wut.Workspace.Git.Blame
---@field hash string
---@field old_line_number number
---@field new_line_number number
---@field group number
---@field author Wut.Workspace.Git.Blame.Author
---@field committer Wut.Workspace.Git.Blame.Committer
---@field summary string

local function parse_header(line)
  local hash, old_linenr, new_linenr =
    string.match(line, "^(%x+) (%d+) (%d+)(.*)$")

  return hash, old_linenr, new_linenr
end

local function parse_author(lines)
  local name = string.match(lines[1], "^author (.*)$")
  local email = string.match(lines[2], "^author%-mail <(.*)>$")
  local time = string.match(lines[3], "^author%-time (.*)$")
  local timezone = string.match(lines[4], "^author%-tz (.*)$")

  return {
    name = name,
    email = email,
    time = tonumber(time),
    timezone = timezone,
  }
end

local function parse_committer(lines)
  local name = string.match(lines[1], "^committer (.*)$")
  local email = string.match(lines[2], "^committer%-mail <(.*)>$")
  local time = string.match(lines[3], "^committer%-time (.*)$")
  local timezone = string.match(lines[4], "^committer%-tz (.*)$")

  return {
    name = name,
    email = email,
    time = tonumber(time),
    timezone = timezone,
  }
end

local function parse_summary(line)
  local summary = string.match(line, "^summary (.*)$")

  return summary
end

---@return Wut.Workspace.Git.Blame
return function(output)
  vim.pretty_print(output)
  local hash, old_line_number, new_line_number = parse_header(output[1])
  local author = parse_author {
    output[2],
    output[3],
    output[4],
    output[5],
  }
  local committer = parse_committer {
    output[6],
    output[7],
    output[8],
    output[9],
  }
  local summary = parse_summary(output[10])

  return {
    hash = hash,
    old_line_number = tonumber(old_line_number),
    new_line_number = tonumber(new_line_number),
    author = author,
    committer = committer,
    summary = summary,
  }
end
