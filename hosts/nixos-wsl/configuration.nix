# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  networking.hostName = "nixos-wsl";

  wsl.enable = true;
  wsl.defaultUser = "lucas";

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}

