return {
  {
    "undotree",
    auto_enable = true,
    cmd = { "UndotreeToggle", "UndotreeFocus" },
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree" },
    },
    -- Undotree is an older Vim plugin. It relies on global variables instead of a setup() function.
    -- We use `before` so these globals are set *before* the plugin loads!
    before = function()
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
      -- Highly recommended: Turn on persistent undo so history is saved between Neovim restarts
      if vim.fn.has("persistent_undo") == 1 then
        vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
        vim.opt.undofile = true
      end
    end,
  },
}
