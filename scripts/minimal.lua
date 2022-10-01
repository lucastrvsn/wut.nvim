local root_dir = vim.fn.getcwd()

local function join(...)
  return table.concat(vim.tbl_flatten { ... }, "/")
end

local paths = {
  wut = root_dir,
  treesitter = join(root_dir, ".plugins", "nvim-treesitter"),
  treesitter_parsers = join(root_dir, ".plugins", ".parsers"),
  lspconfig = join(root_dir, ".plugins", "nvim-lspconfig"),
}

vim.opt.runtimepath:append(paths.wut)
vim.opt.runtimepath:append(paths.treesitter)
vim.opt.runtimepath:append(paths.treesitter_parsers)
vim.opt.runtimepath:append(paths.lspconfig)

vim.cmd [[runtime! plugin/nvim-treesitter.lua]]
vim.cmd [[runtime! plugin/lspconfig.lua]]

vim.o.swapfile = false
vim.bo.swapfile = false

require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua" },
  sync_install = false,
  auto_install = false,
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
