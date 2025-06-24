# Desktop environment and GUI applications
# Minimal desktop setup with qtile window manager

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Essential desktop applications
    firefox
    thunderbird
    libreoffice

    # Media
    vlc

    # Utilities
    flameshot
    xclip
    remmina

    # Audio control
    pavucontrol

    # Background/wallpaper management
    nitrogen # GUI wallpaper manager
    feh # Command-line wallpaper setter
  ];

  # X11 and qtile
  services.xserver = {
    enable = lib.mkDefault true;
    windowManager.qtile.enable = lib.mkDefault true;

    # Set default background (optional - you can change this path)
    displayManager.sessionCommands = ''
      ${pkgs.feh}/bin/feh --bg-scale ~/.background-image || ${pkgs.feh}/bin/feh --bg-fill /run/current-system/sw/share/pixmaps/nixos-logo.png
    '';
  };

  # Display manager
  # services.displayManager.sddm.enable = lib.mkDefault true;

  # Desktop services
  services = {
    printing.enable = lib.mkDefault true; # Enable printing support
    blueman.enable = lib.mkDefault true; # Bluetooth manager
    picom.enable = lib.mkDefault true; # Compositor for transparency and effects
  };

  # Audio
  # services.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };

  # Essential fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    fira-code

    # Nerd Fonts for terminal/editor icons
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    nerd-fonts.dejavu-sans-mono
  ];

  # Network management
  networking.networkmanager.enable = true;
}
