local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(bufnr, "testing")
vim.fn.setbufvar(bufnr, "&buftype", "nofile")

local opts = {
  relative = "cursor",
  row = 1,
  col = 1,
  width = 14,
  height = 10,
  focusable = false,
  style = "minimal",
  border = "shadow",
}

local M = {}

M.completion = {
  items = {},
  timer = vim.loop.new_timer(),
}

M.setup = function()
  vim.api.nvim_create_autocmd({ "TextChangedI" }, {
    callback = function()
      vim.lsp.buf_request_all(
        0,
        "textDocument/completion",
        vim.lsp.util.make_position_params(),
        function(response)
          local lines = {}

          for _, i in pairs(response) do
            for _, ii in pairs(i.result) do
              if not ii then
                return
              end

              -- vim.list_extend(M.completion.items, ii.label)
              table.insert(lines, ii.label)
            end
          end

          M.completion.items = lines

          vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
          vim.api.nvim_open_win(bufnr, false, opts)
        end
      )
    end,
  })

  M.completion.timer:start(1000, 750, function()
    -- vim.lsp.util.stylize_markdown(bufnr, M.completion.items, {})
    -- vim.pretty_print(M.completion.items)
    -- vim.pretty_print(M.completion.items)

    -- vim.lsp.util.convert_input_to_markdown_lines(M.items)
  end)
end

return M
