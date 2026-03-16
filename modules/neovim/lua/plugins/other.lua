return {
  {
    "nvim-treesitter",
    lazy = false,
    auto_enable = true,
    after = function(plugin)
      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        -- check if parser exists and load it
        if not vim.treesitter.language.add(language) then
          return false
        end
        -- enables syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- -- enables treesitter based folds
        -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        -- vim.wo.foldmethod = "expr"
        -- -- ensure folds are open to begin with
        -- vim.o.foldlevel = 99
        --
        -- -- enables treesitter based indentation
        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        return true
      end

      local installable_parsers = require("nvim-treesitter").get_available()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          if not treesitter_try_attach(buf, language) then
            if vim.tbl_contains(installable_parsers, language) then
              -- not already installed, so try to install them via nvim-treesitter if possible
              require("nvim-treesitter").install(language):await(function()
                treesitter_try_attach(buf, language)
              end)
            end
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter-textobjects",
    auto_enable = true,
    lazy = false,
    before = function(plugin)
      -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main?tab=readme-ov-file#using-a-package-manager
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true

      -- Or, disable per filetype (add as you like)
      -- vim.g.no_python_maps = true
      -- vim.g.no_ruby_maps = true
      -- vim.g.no_rust_maps = true
      -- vim.g.no_go_maps = true
    end,
    after = function(plugin)
      require("nvim-treesitter-textobjects").setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true of false
          include_surrounding_whitespace = false,
        },
      }

      -- keymaps
      -- You can use the capture groups defined in `textobjects.scm`
      vim.keymap.set({ "x", "o" }, "am", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "im", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
      end)
      -- You can also use captures from other query groups like `locals.scm`
      vim.keymap.set({ "x", "o" }, "as", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
      end)

      -- NOTE: for more textobjects options, see the following link.
      -- This template is using the new `main` branch of the repo.
      -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    end,
  },
  {
    "conform.nvim",
    auto_enable = true,
    -- cmd = { "" },
    -- event = "",
    -- ft = "",
    keys = {
      { "<leader>FF", desc = "[F]ormat [F]ile" },
    },
    -- colorscheme = "",
    after = function(plugin)
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = nixInfo(nil, "settings", "cats", "lua") and { "stylua" } or nil,
          python = nixInfo(nil, "settings", "cats", "python") and { "isort", "black" } or nil, -- sorts imports first, then formats code
          javascript = nixInfo(nil, "settings", "cats", "javascript") and { "prettierd" } or nil,
          typescript = nixInfo(nil, "settings", "cats", "javascript") and { "prettierd" } or nil,
          javascriptreact = nixInfo(nil, "settings", "cats", "javascript") and { "prettierd" } or nil,
          typescriptreact = nixInfo(nil, "settings", "cats", "javascript") and { "prettierd" } or nil,
          -- Use a sub-list to run only the first available formatter
          -- javascript = { { "prettierd", "prettier" } },
          -- go = { "gofmt", "golint" },
          -- templ = { "templ" },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>FF", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[F]ormat [F]ile" })
    end,
  },
  {
    "nvim-lint",
    auto_enable = true,
    -- cmd = { "" },
    event = "FileType",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('lint').linters_by_ft = {
        -- NOTE: download some linters
        -- and configure them here
        -- markdown = {'vale',},
        python = nixInfo(nil, "settings", "cats", "python") and { 'ruff' } or nil,
        javascript = nixInfo(nil, "settings", "cats", "javascript") and { 'eslint_d' } or nil,
        typescript = nixInfo(nil, "settings", "cats", "javascript") and { 'eslint_d' } or nil,
        javascriptreact = nixInfo(nil, "settings", "cats", "javascript") and { 'eslint_d' } or nil,
        typescriptreact = nixInfo(nil, "settings", "cats", "javascript") and { 'eslint_d' } or nil,
        -- javascript = { 'eslint' },
        -- typescript = { 'eslint' },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  {
    "cmp-cmdline",
    auto_enable = true,
    on_plugin = { "blink.cmp" },
    load = nixInfo.lze.loaders.with_after,
  },
  {
    "blink.compat",
    auto_enable = true,
    dep_of = { "cmp-cmdline" },
  },
  {
    "colorful-menu.nvim",
    auto_enable = true,
    on_plugin = { "blink.cmp" },
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function(_)
      require("blink.cmp").setup({
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- See :h blink-cmp-config-keymap for configuring keymaps
        keymap = {
          preset = 'default',
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            -- Search forward and backward
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Commands
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
        },
        fuzzy = {
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        sources = {
          default = { 'lsp', 'path', 'buffer', 'omni' },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
          },
        },
      })
    end,
  },
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
  {
    "nvim-origami",
    auto_enable = true,
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("origami").setup({ })
    end,
  },
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
    "vim-startuptime",
    auto_enable = true,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, "progpath")
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
    "jupytext.nvim",
    auto_enable = true,
    -- We must intercept .ipynb files the second Neovim tries to open them
    event = { "BufReadCmd *.ipynb", "BufNewFile *.ipynb" },
    after = function()
      require("jupytext").setup({
        style = "percent",
        output_extension = "ju.py",
      })
    end,
  },
}
