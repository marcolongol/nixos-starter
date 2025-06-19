{
  description = "NixOS Configuration Management System";

  inputs = {
    # nixpkgs - Nix Packages collection
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nixos-wsl - NixOS-WSL modules
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # flake-parts - very lightweight flake framework
    # https://flake.parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # home-manager - home user modules
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    let
      lib = import ./lib {
        inherit inputs;
        hostsDir = ./hosts;
      };
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Task runner
            go-task

            # Nix tools
            nixfmt-classic
            nixd # Nix language server

            # Development tools for parsing and manipulating Nix files
            nodejs_20
            nodePackages.typescript
            nodePackages.ts-node
          ];

          shellHook = ''
            echo "🚀 NixOS Config Management Environment"
            echo "Available tools:"
            echo "  - task: Run management tasks"
            echo "  - nixfmt: Format Nix files"
            echo "  - nil: Nix language server"
            echo ""
            echo "Run 'task --list' to see available tasks"
            echo "Run 'task cleanup --force' to reset to clean state"
          '';
        };
      };
      flake = {
        nixosConfigurations = {
          nixos-wsl = lib.mkSystem {
            hostname = "nixos-wsl";
            profiles = [ "common" "security" "development" ];
            users = [{
              name = "lucas";
              profiles = [ "developer" ];
              extraGroups = [ "wheel" ];
            }];
            extraModules = [ inputs.nixos-wsl.nixosModules.wsl ];
          };
          nixos-lt = lib.mkSystem {
            hostname = "nixos-lt";
            profiles = [ "common" "desktop" "security" "development" ];
            users = [{
              name = "lucas";
              profiles = [ "developer" ];
              extraGroups = [ "wheel" "networkmanager" ];
            }];
            extraModules = [ ];
          };
        };
      };
    };
}
