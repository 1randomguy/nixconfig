return {
  {
    "mini.surround",
    auto_enable = true,
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("mini.surround").setup()
    end,
  },
  {
    "nvim-autopairs",
    auto_enable = true,
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- Integrates with Treesitter so it doesn't auto-pair inside strings/comments
      })
    end,
  },
  {
    "todo-comments.nvim",
    auto_enable = true,
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TodoTelescope", "TodoLocList", "TodoQuickFix" },
    after = function()
      require("todo-comments").setup()
    end,
  },
  {
    "toggleterm.nvim",
    auto_enable = true,
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      -- Tell lze to load the plugin the first time you press Ctrl+t
      { "<C-t>", "<cmd>ToggleTerm<CR>", desc = "Toggle Floating Terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<CR>", desc = "Terminal Horizontal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal Float" },
    },
    after = function()
      require("toggleterm").setup({
        open_mapping = [[<C-t>]], -- This binds Ctrl+t to toggle the terminal globally
        direction = "float",      -- Makes it float by default
        float_opts = {
          border = "curved",      -- single, double, shadow, or curved
        },
      })
    end,
  },
  {
    "yazi.nvim",
    auto_enable = true,
    after = function (plugin)
      require("yazi").setup({
        open_for_directories = false,
        -- You can configure the floating window here
        -- floating_window_scaling_factor = 0.9,
        -- yazi_floating_window_winblend = 10,
      })
      vim.keymap.set("n", "-", function() require("yazi").yazi() end, { desc = 'Open Yazi at current file' })
      -- { "<leader>fw", "<cmd>Yazi cwd<CR>", desc = "Open Yazi in working directory" },
      -- { "<leader><up>", "<cmd>Yazi toggle<CR>", desc = "Resume last Yazi session" }
    end
  },
  {
    "nvim-origami",
    auto_enable = true,
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("origami").setup({ })
    end,
  },
  {
    "vim-startuptime",
    auto_enable = true,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, "progpath")
    end,
  },
}
