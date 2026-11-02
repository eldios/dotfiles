return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    local bundled = {
      vim = true, vimdoc = true, c = true, lua = true,
      markdown = true, markdown_inline = true, query = true,
    }
    if type(opts.ensure_installed) == "table" then
      opts.ensure_installed = vim.tbl_filter(function(p)
        return not bundled[p]
      end, opts.ensure_installed)
    end
  end,
}
