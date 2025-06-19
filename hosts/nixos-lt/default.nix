# Host Configuration Loader
# Loads the configuration.nix for nixos-lt

{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./configuration.nix ];
}
