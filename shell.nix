{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Task runner
    go-task

    # Nix tools
    nixfmt-classic
    nixd # Nix language server
  ];

  shellHook = ''
    echo "🚀 NixOS Config Environment - Run 'task --list' for available tasks"
  '';
}
