{pkgs, ...}:
{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono 
      nerd-fonts.jetbrains-mono
      noto-fonts-cjk-serif
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono" ];
      };
    };
  };
}
