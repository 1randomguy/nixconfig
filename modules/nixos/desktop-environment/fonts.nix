{
  flake.nixosModules.fonts = {pkgs, ...}:
  {
    fonts = {
      packages = with pkgs; [
        jetbrains-mono 
        nerd-fonts.jetbrains-mono
        noto-fonts-cjk-serif
        noto-fonts-cjk-sans
        noto-fonts-lgc-plus
        noto-fonts-color-emoji
        montserrat
        fira-go
        fira-math
        kanji-stroke-order-font
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "JetBrainsMono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
