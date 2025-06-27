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

    # nixvim - Neovim configuration framework
    # https://github.com/nix-community/nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
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
        devShells.default = import ./shell.nix { inherit pkgs; };
      };
      flake = {
        nixosConfigurations = {
          nixos-wsl = lib.mkSystem {
            hostname = "nixos-wsl";
            profiles = [ "security" "development" ];
            users = [{
              name = "lucas";
              profiles = [ "admin" "developer" ];
              extraGroups = [ "wheel" ];
            }];
            extraModules = [ inputs.nixos-wsl.nixosModules.wsl ];
          };
          nixos-lt = lib.mkSystem {
            hostname = "nixos-lt";
            profiles = [ "desktop" "security" "development" "gaming" ];
            users = [{
              name = "lucas";
              profiles = [ "admin" "developer" ];
              extraGroups = [ "wheel" "networkmanager" ];
            }];
            extraModules = [ ./modules/nvidia ];
          };
        };
      };
    };
}
