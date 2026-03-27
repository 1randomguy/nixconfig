return {
  {
    "fidget.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require('fidget').setup({})
    end,
  },
  -- {
  --   "lualine.nvim",
  --   auto_enable = true,
  --   -- cmd = { "" },
  --   event = "DeferredUIEnter",
  --   -- ft = "",
  --   -- keys = "",
  --   -- colorscheme = "",
  --   after = function(plugin)
  --     require('lualine').setup({
  --       options = {
  --         icons_enabled = false,
  --         theme = nixInfo("onedark_dark", "settings", "colorscheme"),
  --         component_separators = '|',
  --         section_separators = '',
  --       },
  --       sections = {
  --         lualine_c = {
  --           { 'filename', path = 1, status = true, },
  --         },
  --       },
  --       inactive_sections = {
  --         lualine_b = {
  --           { 'filename', path = 3, status = true, },
  --         },
  --         lualine_x = { 'filetype' },
  --       },
  --       tabline = {
  --         lualine_a = { 'buffers' },
  --         -- if you use lualine-lsp-progress, I have mine here instead of fidget
  --         -- lualine_b = { 'lsp_progress', },
  --         lualine_z = { 'tabs' }
  --       },
  --     })
  --   end,
  -- },
  {
    "vim-illuminate",
    auto_enable = true,
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      require("illuminate").configure({
        delay = 150, -- Wait 150ms before highlighting so it doesn't flash violently while moving
        large_file_cutoff = 2000, -- Disable on huge files so Neovim doesn't freeze
      })
    end,
  },
  {
    "which-key.nvim",
    auto_enable = true,
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('which-key').setup({
      })
      require('which-key').add {
        { "<leader><leader>",  group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c",         group = "[c]ode" },
        { "<leader>c_",        hidden = true },
        { "<leader>d",         group = "[d]ocument" },
        { "<leader>d_",        hidden = true },
        { "<leader>g",         group = "[g]it" },
        { "<leader>g_",        hidden = true },
        { "<leader>m",         group = "[m]arkdown" },
        { "<leader>m_",        hidden = true },
        { "<leader>r",         group = "[r]ename" },
        { "<leader>r_",        hidden = true },
        { "<leader>s",         group = "[s]earch" },
        { "<leader>s_",        hidden = true },
        { "<leader>t",         group = "[t]oggles" },
        { "<leader>t_",        hidden = true },
        { "<leader>w",         group = "[w]orkspace" },
        { "<leader>w_",        hidden = true },
      }
    end,
  },
}
