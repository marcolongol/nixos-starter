# Individual User Management
# This module handles individual user configurations

{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.customUsers;

  # User configuration type
  userType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Username for the system user";
      };

      profiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of user profiles to apply to this user.
          Note: The "common" profile is automatically included for all users.
        '';
        example = [ "developer" "admin" ];
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "wheel" "networkmanager" ];
        description = "Groups for the user to be part of";
        example = [ "wheel" "networkmanager" "docker" ];
      };
    };
  };

in {
  options.customUsers = {
    users = lib.mkOption {
      type = lib.types.listOf userType;
      default = [ ];
      description = ''
        List of users to create with their respective profiles.
      '';
      example = [
        {
          name = "alice";
          profiles = [ "admin" ];
          extraGroups = [ "wheel" "networkmanager" "systemd-journal" ];
        }
        {
          name = "bob";
          profiles = [ "developer" ];
          extraGroups = [ "wheel" "networkmanager" "docker" ];
        }
      ];
    };
  };

  config = lib.mkIf (cfg.users != [ ]) {
    # Create system users
    users.users = lib.listToAttrs (map (user: {
      name = user.name;
      value = {
        isNormalUser = true;
        extraGroups = user.extraGroups;
        shell = pkgs.zsh;
        description = "User managed by users";
      };
    }) cfg.users);

    # Enable zsh system-wide
    programs.zsh.enable = true;

    # Configure home-manager for each user
    home-manager.users = lib.listToAttrs (map (user: {
      name = user.name;
      value = lib.mkMerge ([
        # Apply all user profiles
        (lib.mkMerge (map (profile:
          import (../profiles/users + "/${profile}.nix") {
            inherit config lib pkgs inputs;
          }) user.profiles))
      ] ++
        # Add individual user configuration if it exists
        lib.optional (builtins.pathExists (./. + "/${user.name}.nix"))
        (import (./. + "/${user.name}.nix") {
          inherit config lib pkgs inputs;
        }));
    }) cfg.users);
  };
}
