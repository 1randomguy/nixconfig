return {
  {
    "rustaceanvim",
    -- The Magic Shield: Only enable this if `config.specs.rust.enable = true` in Nix!
    for_cat = "rust",
    -- Only load this plugin when we actually open a Rust file
    ft = "rust",
    -- rustaceanvim expects configuration in a global variable BEFORE it loads
    before = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              -- Tell rust-analyzer to use clippy on save!
              checkOnSave = {
                command = "clippy",
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
      }
    end,
  },
}
