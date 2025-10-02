return {
  "m4xshen/hardtime.nvim",
  lazy = false,
  opts = function(_, opts)
    local hardtime = require("hardtime")
    Snacks.toggle({
      name = "Hardtime",
      get = function()
        return hardtime.is_plugin_enabled
      end,
      set = function()
        hardtime.toggle()
      end,
    }):map("<leader>H")
    return opts
  end,
}
