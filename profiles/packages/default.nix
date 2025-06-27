# Package Profiles Management
# This module handles the selection and loading of package profiles

{ config, lib, pkgs, ... }:

let
  cfg = config.packageProfiles;

  # Dynamically discover available package profiles by scanning the directory
  availableProfiles = let
    # Get all .nix files in the current directory except default.nix
    profileFiles =
      lib.filter (name: lib.hasSuffix ".nix" name && name != "default.nix")
      (builtins.attrNames (builtins.readDir ./.));
    # Remove the .nix extension to get profile names
    profileNames = map (name: lib.removeSuffix ".nix" name) profileFiles;
  in profileNames;

in {
  options.packageProfiles = {
    enable = lib.mkOption {
      type = lib.types.listOf (lib.types.enum availableProfiles);
      default = [ ];
      description = ''
        List of package profiles to enable.
        Available profiles: ${lib.concatStringsSep ", " availableProfiles}

        Profile descriptions:
        - common: Essential packages for all systems
        - desktop: Minimal GUI environment with qtile
        - development: Programming tools and environments
        - security: Security hardening and monitoring tools
        - gaming: Gaming platforms, performance tools, and hybrid graphics support
      '';
      example = [ "desktop" "development" "security" ];
    };
  };

  # Apply the selected profiles by merging their configurations
  config = lib.mkMerge ([
    # Always include common profile when any profiles are enabled
    (lib.mkIf (cfg.enable != [ ])
      (import ./common.nix { inherit config lib pkgs; }))
  ] ++ (map (profile:
    lib.mkIf (lib.elem profile cfg.enable)
    (import (./. + "/${profile}.nix") { inherit config lib pkgs; }))
    availableProfiles));
}
