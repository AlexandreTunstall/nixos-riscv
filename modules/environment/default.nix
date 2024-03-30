{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./neovim.nix
  ];

  environment.systemPackages = [
    pkgs.mtdutils
    pkgs.nix-output-monitor
    pkgs.tmux
  ];

  nix.settings = {
    keep-derivations = true;
    keep-outputs = true;
  };
}
