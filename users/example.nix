# Example user configuration
# Copy this file and rename it to your username.nix
# Example: cp users/example.nix users/alice.nix

{ pkgs, ... }: {
  # Personal git configuration
  programs.git = {
    userName = "Your Full Name";
    userEmail = "your.email@example.com";
  };

  # Personal packages
  home.packages = with pkgs;
    [
      # Add your favorite packages here
      # Example packages (uncomment to use):
      # firefox
      # discord
      # obsidian
      # spotify

      # This empty placeholder prevents linting errors
      hello
    ];

  # Personal shell aliases
  programs.zsh.shellAliases = {
    # Add your personal aliases here
    # work = "cd ~/workspace";
    # dots = "cd ~/.config";
    # nixconfig = "cd /etc/nixos";
  };

  # Personal environment variables
  home.sessionVariables = {
    # Add your environment variables here
    # EDITOR = "code";
    # BROWSER = "firefox";
  };

  # Personal program configurations
  # Uncomment and customize as needed

  # programs.firefox = {
  #   enable = true;
  #   # Add Firefox configuration here
  # };

  # programs.vscode = {
  #   enable = true;
  #   # Add VS Code configuration here
  # };
}
