{pkgs, ...}:
{
  imports = [
    ./homelab
    ./workstation
  ];

  i18n.supportedLocales = ["en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8"];
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
    LC_TIME = "en_DK.UTF-8";
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "en_DK.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_COLLATE = "de_DE.UTF-8";
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
}
