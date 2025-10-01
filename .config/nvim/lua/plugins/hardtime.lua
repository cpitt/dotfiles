return {
  "m4xshen/hardtime.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {},
  keys = {
    {
      "<leader>h",
      function()
        vim.cmd("Hardtime toggle")
        vim.notify("Hardtime toggled!", vim.log.levels.INFO)
      end,
      desc = "Toggle Hardtime",
    },
  },
}
