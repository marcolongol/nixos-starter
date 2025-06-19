# Host Configuration Loader
# Loads the configuration.nix for the current host

{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ./configuration.nix ];
}
