# Developer User Profile
# Comprehensive development environment with modern tooling

{ pkgs, ... }:

{
  # Import common user profile
  imports = [ ./common.nix ];

  # Development packages (extends common packages)
  home.packages = with pkgs; [
    # Terminal enhancements
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    eza
    bat
    fzf
    zoxide

    # Development tools
    lazygit
    delta

    # Language tools
    tree-sitter
    shellcheck

    # System utilities
    bottom
    dust
    procs
  ];

  # Extended shell configuration for developers
  programs.zsh = {
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Developer-specific aliases (extends common aliases)
      ls = "eza";
      ll = "eza -la"; # Override common ll
      cat = "bat";
      cd = "z";
      top = "btm";
      du = "dust";
      ps = "procs";
    };

    initContent = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # Initialize starship
      eval "$(starship init zsh)"
    '';
  };

  # Extended git configuration
  programs.git = {
    delta.enable = true;
    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Direnv for project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      right_format = "$time";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      time = {
        disabled = false;
        format = "[$time](dimmed white)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    extraConfig = ''
      # Mouse support
      set -g mouse on

      # Status bar
      set -g status-bg colour234
      set -g status-fg colour137

      # Window navigation
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R
    '';
  };
}
