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
    coreutils

    # Basic text processing
    ripgrep
    jq
  ];

  # Enable joke MOTD module
  programs.joke-motd = {
    enable = lib.mkDefault true;
    fetchInterval = "10min"; # Fetch new jokes every 10 minutes
    showOnLogin = lib.mkDefault true; # Show MOTD on interactive shell login
  };

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

  # Basic security
  security.sudo.wheelNeedsPassword = false;
}
