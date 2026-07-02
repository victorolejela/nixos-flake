{ config, pkgs, ... }:

{
  home.username = "venom";
  home.homeDirectory = "/home/venom";
  home.stateVersion = "23.11";

  programs.git.enable = true;
  programs.zsh.enable = true;

  home.packages = with pkgs; [
    neovim
    htop
    tree
    firefox
    easyeffects
  ];
}
