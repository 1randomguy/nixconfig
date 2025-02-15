{pkgs, ...}:
{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono 
      nerd-fonts.jetbrains-mono
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono" ];
      };
    };
  };
}
