# Lucas's Individual User Configuration
# This file contains custom configurations specific to Lucas
# It extends the base developer profile with personal preferences
{ lib
, pkgs
, ...
}:
let
  onePassPath = "~/.1password/agent.sock";
in
{
  # Disable nixpkgs version mismatch warnings
  home.enableNixpkgsReleaseCheck = false;

  # Lucas's personal git configuration
  programs.git = {
    userName = "Lucas Marcolongo";
    userEmail = "lucas_marco@live.com";
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      commit.gpgSign = false;
    };
  };

  # Additional packages specific to Lucas
  home.packages = with pkgs; [
    # Personal productivity tools
    obsidian
    discord
    _1password-gui
    _1password-cli

    # version control and development tools
    gh

    # Communication tools
    webex

    # Additional development tools
    docker-compose
    k9s
    kubectl
  ];

  # Custom shell aliases for Lucas
  programs.zsh.shellAliases = {
    # Personal shortcuts
    work = "cd ~/work";
    personal = "cd ~/personal";
    nixconfig = "cd /etc/nixos";

    # Docker shortcuts
    dps = "docker ps";
    dcup = "docker-compose up -d";
    dcdown = "docker-compose down";
  };

  # Lucas's specific environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ${onePassPath}
    '';
  };

  home.file.".config/alacritty/alacritty.toml".text = ''
    [window]
    title = "Lucas's Terminal"
    opacity = 0.6
    blur = true
    padding.x = 10
    padding.y = 10
    decorations = "Full"
    decorations_theme_variant = "dark"
    [font]
    size = 9.0
    [colors]
    primary.background = "#282c34"
    primary.foreground = "#abb2bf"
    cursor.background = "#528bff"
    cursor.foreground = "#ffffff"
    selection.background = "#3e4451"
    selection.foreground = "#ffffff"
  '';

  # Custom home directory structure
  home.file = {
    ".config/personal-scripts/.keep".text = "";
    "work/.keep".text = "";
    "personal/.keep".text = "";
  };
}
