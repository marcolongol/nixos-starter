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

    # Custom MOTD joke fetcher (from overlays)
    custom.joke-motd
  ];

  # Systemd service to fetch jokes periodically
  systemd.services.motd-joke-fetcher = {
    description = "Fetch joke for MOTD";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.custom.joke-motd}/bin/joke-motd";
      User = "root";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Systemd timer to run the joke fetcher every 10 minutes
  systemd.timers.motd-joke-fetcher = {
    description = "Timer for MOTD joke fetcher";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min"; # First run 1 minute after boot
      OnUnitActiveSec = "10min"; # Then every 10 minutes
      Persistent = true;
    };
  };

  # Set the custom MOTD to run our joke fetcher
  users.motd = ""; # Disable default motd

  # Override default MOTD display for interactive shells
  environment.etc."profile.local".text = ''
    # Custom MOTD display on login
    if [[ $- == *i* ]] && [[ -z "$MOTD_SHOWN" ]]; then
      export MOTD_SHOWN=1
      ${pkgs.custom.joke-motd}/bin/joke-motd
    fi
  '';

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
