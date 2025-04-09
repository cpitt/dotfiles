return {
  "frankroeder/parrot.nvim",
  enable = false,
  dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
  config = function()
    require("parrot").setup({
      providers = {
        openai = {
          api_key = os.getenv("OPENAI_API_KEY"),
        },
      },
    })
  end,
}
