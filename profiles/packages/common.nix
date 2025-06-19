# Common packages shared across all systems
# Minimal essential tools for all systems

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Essential CLI tools
    wget
    curl
    git
    vim
    htop
    tree
    unzip
    file
    openssh

    # System information and utilities
    pfetch
    lshw
    busybox

    # Basic text processing
    ripgrep
    jq
  ];

  # SSH service with secure defaults
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      # Security hardening
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      PubkeyAuthentication = lib.mkDefault true;
      AuthenticationMethods = lib.mkDefault "publickey";

      # Connection settings
      ClientAliveInterval = lib.mkDefault 300;
      ClientAliveCountMax = lib.mkDefault 2;
      MaxAuthTries = lib.mkDefault 3;

      # Protocol settings
      Protocol = lib.mkDefault 2;
      X11Forwarding = lib.mkDefault false;
      AllowAgentForwarding = lib.mkDefault false;
      AllowTcpForwarding = lib.mkDefault "local";
    };

    # Only allow wheel group (sudoers) to SSH
    extraConfig = ''
      AllowGroups wheel
    '';
  };

  # Nix configuration
  nix = { settings.experimental-features = [ "nix-command" "flakes" ]; };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Basic security
  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
