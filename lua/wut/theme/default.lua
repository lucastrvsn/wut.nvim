local hl = require "wut/highlight"
local color = require "wut/color"

-- Base16 colors
-- See: https://github.com/chriskempson/base16
local colors = {
  base00 = color.from "#282828", -- Default Background
  base01 = color.from "#3c3836", -- Lighter Background (Used for status bars, line number and folding marks)
  base02 = color.from "#504945", -- Selection Background
  base03 = color.from "#665c54", -- Comments, Invisibles, Line Highlighting
  base04 = color.from "#bdae93", -- Dark Foreground (Used for status bars)
  base05 = color.from "#d5c4a1", -- Default Foreground, Caret, Delimiters, Operators
  base06 = color.from "#ebdbb2", -- Light Foreground (Not often used)
  base07 = color.from "#fbf1c7", -- Light Background (Not often used)
  base08 = color.from "#fb4934", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = color.from "#fe8019", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0a = color.from "#fabd2f", -- Classes, Markup Bold, Search Text Background
  base0b = color.from "#b8bb26", -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0c = color.from "#8ec07c", -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0d = color.from "#83a598", -- Functions, Methods, Attribute IDs, Headings
  base0e = color.from "#d3869b", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0f = color.from "#d65d0e", -- Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
}

return {
  ["StatuslineModeNormal"] = {
    highlight = hl.create {
      name = "StatuslineModeNormal",
      style = {
        fg = colors.base02,
        bg = colors.base00,
      },
    },
  },
  ["StatuslineModeVisual"] = {
    highlight = hl.create {
      name = "StatuslineModeVisual",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModeSelect"] = {
    highlight = hl.create {
      name = "StatuslineModeSelect",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModeInsert"] = {
    highlight = hl.create {
      name = "StatuslineModeInsert",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModeReplace"] = {
    highlight = hl.create {
      name = "StatuslineModeReplace",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModeCommand"] = {
    highlight = hl.create {
      name = "StatuslineModeCommand",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModePrompt"] = {
    highlight = hl.create {
      name = "StatuslineModePrompt",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModeShell"] = {
    highlight = hl.create {
      name = "StatuslineModeShell",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineModeTerminal"] = {
    highlight = hl.create {
      name = "StatuslineModeTerminal",
      style = {
        bg = colors.base02,
      },
    },
  },
  ["StatuslineDiagnosticsError"] = {
    icon = "E",
    highlight = hl.create {
      name = "StatuslineDiagnosticsError",
      style = {
        fg = colors.base08,
      },
    },
  },
  ["StatuslineDiagnosticsWarn"] = {
    icon = "W",
    highlight = hl.create {
      name = "StatuslineDiagnosticsWarn",
      style = {
        fg = colors.base04,
      },
    },
  },
  ["StatuslineDiagnosticsInfo"] = {
    icon = "I",
    highlight = hl.create {
      name = "StatuslineDiagnosticsInfo",
      style = {
        fg = colors.base03,
      },
    },
  },
  ["StatuslineDiagnosticsHint"] = {
    icon = "H",
    highlight = hl.create {
      name = "StatuslineDiagnosticsHint",
      style = {
        fg = colors.base01,
      },
    },
  },
}
