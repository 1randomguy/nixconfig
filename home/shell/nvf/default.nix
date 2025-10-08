{ inputs, config, pkgs, lib, ... }:
let
  cfg = config.shell.nvf;
in
{
  imports = [
      inputs.nvf.homeManagerModules.default
  ];

  options.shell.nvf = {
    enable = lib.mkEnableOption "my neovim config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # dependencies
      imagemagick
      ripgrep
      fd
    ];
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };

          clipboard = {
            enable = true;
            providers.wl-copy.enable = true;
          };

          utility.images = {
            image-nvim = {
              enable = true;
              setupOpts = {
                backend = "kitty";
                integrations.markdown = {
                  enable = true;
                  #clearInInsertMode = true;
                  only_render_at_cursor = true; #idk why this wont work 
                  only_render_at_cursor_mode = "popup";
                  floating_windows = true;
                };
              };
            };
            img-clip.enable = true;
          };

          statusline.lualine.enable = true;

          utility.yazi-nvim = {
            enable = true;
          };

          git = {
            enable = true;
          };

          mini = {
            surround.enable = true;
            bufremove.enable = true;
          };

          ui = {
            illuminate.enable = true;
          };

          notes.todo-comments = {
            enable = true;
            mappings = {
              quickFix = "<leader>tdq";
              telescope = "<leader>tds";
            };
          };

          options = {
            tabstop = 2;
            shiftwidth = 2;
            softtabstop = 0;
            expandtab = true;
            smarttab = true;
          };

          terminal.toggleterm = {
            enable = true;
            setupOpts = {
              open_mapping = "<C-t>";  # Add this line
              insert_mappings = true;
              terminal_mappings = true;
            };
            lazygit.enable = true;
          };

          telescope.enable = true;

          autopairs.nvim-autopairs.enable = true;

          binds = {
            hardtime-nvim.enable = true;
            cheatsheet.enable = true;
          };

          languages = {
            enableTreesitter = true;
            
            nix.enable = true;
            markdown.enable = true;
            typst.enable = true;
            bash.enable = true;
            python.enable = true;
            ts.enable = true;
            clang.enable = true;
            yaml = {
              enable = true; # somehow weird
              treesitter.enable = false;
            };
          };

          lsp = {
            enable = true;
            #formatOnSave = true;
          };

          utility.motion.flash-nvim = {
            enable = true;
            mappings.jump = "<leader>s";
            mappings.treesitter = "S";
          };

          utility.undotree.enable = true;

          autocomplete = {
            blink-cmp = {
              enable = true;
              mappings = {
                close = "<C-e>";
                complete = "<C-Space>";
                confirm = "<C-y>";
                next = "<C-n>";
                previous = "<C-p>";
                scrollDocsDown = "<C-f>";
                scrollDocsUp = "<C-b>";
              };
            };
          };

          ### KEYMAPS
          keymaps = [
            # Split navigation
            {
              mode = "n";
              key = "<C-h>";
              action = "<C-w>h";
              desc = "Move to left split";
            }
            {
              mode = "n";
              key = "<C-j>";
              action = "<C-w>j";
              desc = "Move to split below";
            }
            {
              mode = "n";
              key = "<C-k>";
              action = "<C-w>k";
              desc = "Move to split above";
            }
            {
              mode = "n";
              key = "<C-l>";
              action = "<C-w>l";
              desc = "Move to right split";
            }
            # Window resizing
            {
              mode = "n";
              key = "<C-A-h>";  # Alt+h
              action = "<C-w><";
              desc = "Decrease window width";
            }
            {
              mode = "n";
              key = "<C-A-l>";  # Alt+l
              action = "<C-w>>";
              desc = "Increase window width";
            }
            {
              mode = "n";
              key = "<C-A-j>";  # Alt+j
              action = "<C-w>-";
              desc = "Decrease window height";
            }
            {
              mode = "n";
              key = "<C-A-k>";  # Alt+k
              action = "<C-w>+";
              desc = "Increase window height";
            }
            { 
              mode = "n";
              action = "<cmd>noh<CR>";
              key = "<leader>n";
              desc = "stop highlighting";
            }
            # Plugins
            {
              mode = "n";
              action = "<cmd>UndotreeToggle<CR>";
              key = "<leader>ut";
            }
            {
              mode = "n";
              action = "<cmd>lua MiniBufremove.delete()<CR>";
              key = "<leader>bd";
            }
            # Exit Terminal
            { 
              mode = "t";
              action = "<C-\\><C-n>";
              key = "<C-k><C-k>";
              noremap = true;
            }
          ];
        };
      };
    };
  };
}
