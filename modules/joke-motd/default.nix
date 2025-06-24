# Joke MOTD Module
# Provides a custom MOTD with system information and daily jokes
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.joke-motd;

  # Custom MOTD script with jokes from JokeAPI
  joke-motd = pkgs.writeShellScriptBin "joke-motd" (builtins.readFile
    (pkgs.replaceVars ./joke-motd.sh {
      curl = "${pkgs.curl}";
      jq = "${pkgs.jq}";
      util-linux = "${pkgs.util-linux}";
      nettools = "${pkgs.nettools}";
      coreutils = "${pkgs.coreutils}";
      gawk = "${pkgs.gawk}";
      procps = "${pkgs.procps}";
    }));
in {
  options.programs.joke-motd = {
    enable = mkEnableOption "Enable joke MOTD with system information";

    fetchInterval = mkOption {
      type = types.str;
      default = "10min";
      description = "How often to fetch new jokes";
    };

    showOnLogin = mkOption {
      type = types.bool;
      default = true;
      description = "Show MOTD on interactive shell login";
    };
  };

  config = mkIf cfg.enable {
    # Install the joke-motd script
    environment.systemPackages = [ joke-motd ];

    # Systemd service to fetch jokes periodically
    systemd.services.motd-joke-fetcher = {
      description = "Fetch joke for MOTD";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${joke-motd}/bin/joke-motd";
        User = "root";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Systemd timer to run the joke fetcher periodically
    systemd.timers.motd-joke-fetcher = {
      description = "Timer for MOTD joke fetcher";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min"; # First run 1 minute after boot
        OnUnitActiveSec = cfg.fetchInterval; # Then every configured interval
        Persistent = true;
      };
    };

    # Set the custom MOTD to run our joke fetcher
    users.motd = ""; # Disable default motd

    # Override default MOTD display for interactive shells
    environment.etc."profile.local" = mkIf cfg.showOnLogin {
      text = ''
        # Custom MOTD display on login
        if [[ $- == *i* ]] && [[ -z "$MOTD_SHOWN" ]]; then
          export MOTD_SHOWN=1
          ${joke-motd}/bin/joke-motd
        fi
      '';
    };
  };
}
