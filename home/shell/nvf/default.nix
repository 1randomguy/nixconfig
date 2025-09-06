{ config, pkgs, lib, ... }:
let
  cfg = config.shell.nvf;
in
{
  options.shell.nvf = {
    enable = lib.mkEnableOption "my neovim config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # dependencies
      ripgrep
      fd
    ];
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          viAlias = true;
          #vimAlias = true;

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };

          statusline.lualine.enable = true;

          utility.yazi-nvim = {
            enable = true;
          };

          git = {
            enable = true;
          };

          terminal.toggleterm = {
            enable = true;
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
            rust.enable = true;
          };

          lsp = {
            enable = true;
            #formatOnSave = true;
          };
        };
      };
    };
  };
}
