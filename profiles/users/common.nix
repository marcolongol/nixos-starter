# Common User Profile
# Base configuration shared across all user profiles

{ pkgs, lib, ... }:

{
  # Home directory management
  home.stateVersion = "24.11";

  # Essential packages for all users
  home.packages = with pkgs; [
    # Basic CLI tools
    curl
    wget
    tree
    file
    unzip
  ];

  # Basic shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Common aliases for all users
    shellAliases = lib.mkDefault {
      ll = "ls -l";
      la = "ls -la";
      grep = "grep --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  # Basic git configuration
  programs.git = {
    enable = lib.mkDefault true;
    extraConfig = lib.mkDefault { init.defaultBranch = "main"; };
  };

  # XDG directories
  xdg.enable = lib.mkDefault true;

  # Default background image for all users
  # Users can override this by placing their own .background-image file
  home.file.".background-image" = lib.mkDefault {
    source = ../../assets/default-wallpaper.png; # Path to your wallpaper file
  };

  # Basic environment variables
  home.sessionVariables = lib.mkDefault { PAGER = "less"; };
}
