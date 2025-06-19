# nixos-lt Configuration
# Host-specific configuration for nixos-lt

{ config, lib, pkgs, ... }: {
  networking.hostName = "nixos-lt";

  # Add host-specific configuration here
  imports = [ ./hardware-configuration.nix ];

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Timezone configuration
  time.timeZone = "America/Los_Angeles";
}
