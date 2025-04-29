{pkgs, ...}:
{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono 
      nerd-fonts.jetbrains-mono
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
