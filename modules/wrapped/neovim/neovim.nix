{
  inputs,
  self,
  ...
}:
{
  flake.nvimWrapper =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.neovim ];

      options.settings.minimal = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use a minimal configuration for servers.";
      };

      options.nvim-lib.neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        # Makes plugins autobuilt from our inputs available with
        # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
        default = config.nvim-lib.pluginsFromPrefix "nvim-plugins-" inputs;
      };

      config.settings.config_directory = ./.;

      config.binName = if config.settings.minimal then "nvim-mini" else "nvim";
      config.settings.aliases = [
        "v"
        "vi"
        "vim"
      ];

      # You can declare your own options!
      options.settings.colorscheme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin";
      };

      config.specs.colorscheme = {
        lazy = true;
        data = builtins.getAttr config.settings.colorscheme (
          with pkgs.vimPlugins;
          {
            "onedark_dark" = onedarkpro-nvim;
            "onedark_vivid" = onedarkpro-nvim;
            "onedark" = onedarkpro-nvim;
            "onelight" = onedarkpro-nvim;
            "moonfly" = vim-moonfly-colors;
            "catppuccin" = catppuccin-nvim;
          }
        );
      };

      config.specs.lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];

      config.specs.nix = {
        data = null;
        extraPackages = with pkgs; [
          nixd
          nixfmt
        ];
      };

      config.specs.lua = {
        after = [ "start" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          lazydev-nvim
        ];
        extraPackages = with pkgs; [
          lua-language-server
          stylua
        ];
      };

      config.specs.markdown = {
        enable = !config.settings.minimal;
        data = null;
        extraPackages = with pkgs; [
          marksman
        ];
      };

      config.specs.javascript = {
        enable = !config.settings.minimal;
        data = null;
        extraPackages = with pkgs; [
          typescript-language-server
          prettierd
          eslint_d
        ];
      };

      config.specs.python = {
        enable = !config.settings.minimal;
        data = null;
        extraPackages = with pkgs; [
          pyright
          black
          ruff
        ];
      };

      config.specs.jupyter = {
        enable = !config.settings.minimal;
        data = [
          pkgs.vimPlugins.jupytext-nvim
        ];
        extraPackages = with pkgs; [
          python313Packages.jupytext
        ];
      };

      config.specs.rust = {
        enable = !config.settings.minimal;
        data = with pkgs.vimPlugins; [ rustaceanvim ];
        extraPackages = with pkgs; [
          rust-analyzer
          rustfmt
          cargo
        ];
      };

      config.specs.start = {
        # NOTE: view these names in the info plugin!
        # :lua nixInfo.lze.debug.display(nixInfo.plugins)
        # The display function is from lzextras
        lazy = false;
        data = with pkgs.vimPlugins; [
          {
            data = vim-sleuth;
            lazy = false;
          }
          #lualine-nvim
          gitsigns-nvim
          which-key-nvim
          fidget-nvim
          nvim-treesitter-textobjects
          (
            if config.settings.minimal then
              (nvim-treesitter.withPlugins (
                plugins: with plugins; [
                  nix
                  lua
                  markdown
                  bash
                  json
                  yaml
                  toml
                ]
              ))
            else
              nvim-treesitter.withAllGrammars
          )
        ];
        extraPackages = with pkgs; [
          tree-sitter
        ];
      };

      config.specs.general = {
        after = [ "start" ];
        extraPackages = with pkgs; [
          ripgrep
          fd
          lazygit
          yazi
        ];
        lazy = true;
        # TODO: flash?, image support?, git diff tool?
        data = with pkgs.vimPlugins; [
          colorful-menu-nvim
          nvim-autopairs
          mini-surround
          nvim-lspconfig
          blink-cmp
          blink-compat
          cmp-cmdline
          nvim-lint
          conform-nvim
          diffview-nvim

          undotree
          toggleterm-nvim
          todo-comments-nvim
          vim-illuminate
          nvim-origami
          snacks-nvim
          vim-startuptime
          yazi-nvim
        ];
      };

      config.specMods =
        { ... }:
        {
          options.extraPackages = lib.mkOption {
            type = lib.types.listOf wlib.types.stringable;
            default = [ ];
            description = "a extraPackages spec field to put packages to suffix to the PATH";
          };
        };

      config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

      # Inform our lua of which top level specs are enabled
      options.settings.cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = builtins.mapAttrs (_: v: v.enable) config.specs;
      };
      # build plugins from inputs set
      options.nvim-lib.pluginsFromPrefix = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default =
          prefix: inputs:
          lib.pipe inputs [
            builtins.attrNames
            (builtins.filter (s: lib.hasPrefix prefix s))
            (map (
              input:
              let
                name = lib.removePrefix prefix input;
              in
              {
                inherit name;
                value = config.nvim-lib.mkPlugin name inputs.${input};
              }
            ))
            builtins.listToAttrs
          ];
      };
    };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        imports = [ self.nvimWrapper ];
      };
      packages.neovim-mini = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        imports = [
          self.nvimWrapper
          { settings.minimal = true; }
        ];
      };
    };
}
