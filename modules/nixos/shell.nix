{ self, ... }:
{
  flake.nixosModules.shell = {pkgs, ...}:
  let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in
  {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    environment.systemPackages = [
      selfpkgs.neovim
    ];
  };
}
