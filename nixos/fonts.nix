{pkgs, ...}:
{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono 
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono" ];
      };
    };
  };
}
