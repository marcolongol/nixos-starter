{ hostsDir, inputs, ... }:

let
  lib = inputs.nixpkgs.lib;
  overlays = import ../overlays { inherit inputs; };

  discoverProfiles = dir: fallback:
    if builtins.pathExists dir then
      let
        nixFiles =
          lib.filter (name: lib.hasSuffix ".nix" name && name != "default.nix")
          (lib.attrNames (builtins.readDir dir));
      in map (lib.removeSuffix ".nix") nixFiles
    else
      fallback;

  availableProfiles = discoverProfiles ../profiles/packages [
    "common"
    "desktop"
    "development"
    "security"
  ];

  availableUserProfiles = discoverProfiles ../profiles/users [
    "admin"
    "common"
    "developer"
    "minimal"
  ];

  validateProfiles = profiles:
    let invalidProfiles = lib.subtractLists availableProfiles profiles;
    in lib.assertMsg (invalidProfiles == [ ])
    "Invalid package profiles: ${lib.concatStringsSep ", " invalidProfiles}";

  validateHostPath = hostname:
    lib.assertMsg (builtins.pathExists (hostsDir + "/${hostname}"))
    "Host configuration not found: ${hostsDir}/${hostname}";

  validateUsers = users:
    let
      validateUser = user:
        let
          invalidUserProfiles =
            lib.subtractLists availableUserProfiles user.profiles;
        in lib.assertMsg (invalidUserProfiles == [ ])
        "Invalid user profiles for ${user.name}: ${
          lib.concatStringsSep ", " invalidUserProfiles
        }";
    in lib.all validateUser users;

  coreConfig = nixpkgsConfig: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config = { allowUnfree = true; } // nixpkgsConfig;
    nixpkgs.overlays = overlays;
  };

  homeManagerConfig = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".bak";
    extraSpecialArgs = { inherit inputs; };
  };

  systemInfo = { hostname, profiles, users, system }: {
    environment.etc."nixos-system-info.json".text = builtins.toJSON {
      inherit hostname profiles system;
      users = map (u: { inherit (u) name profiles; }) users;
      architecture = system;
      buildTime = inputs.self.lastModified or "unknown";
      nixosConfigVersion = "1.0.0";
      availablePackageProfiles = availableProfiles;
      availableUserProfiles = availableUserProfiles;
    };

    environment.shellAliases = {
      nixos-info = "cat /etc/nixos-system-info.json | ${
          lib.getExe inputs.nixpkgs.legacyPackages.${system}.jq
        }";
      nixos-profiles = "echo 'Active: ${lib.concatStringsSep ", " profiles}'";
      nixos-rebuild-here =
        "sudo nixos-rebuild switch --flake /etc/nixos#${hostname}";
    };
  };

in {
  mkSystem = { system ? "x86_64-linux", hostname, profiles ? [ ], users ? [ ]
    , extraModules ? [ ], enableSystemInfo ? true, enableValidation ? true
    , nixpkgsConfig ? { } }:
    let
      finalProfiles = if lib.elem "common" profiles then
        profiles
      else
        [ "common" ] ++ profiles;

      finalUsers = map (user:
        if lib.elem "common" user.profiles then
          user
        else
          user // { profiles = [ "common" ] ++ user.profiles; }) users;
    in assert !enableValidation || validateProfiles finalProfiles;
    assert !enableValidation || validateHostPath hostname;
    assert !enableValidation || validateUsers finalUsers;

    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };

      modules = [
        # Core system configuration (base settings, overlays, unfree packages)
        (coreConfig nixpkgsConfig)

        # Host-specific configuration (hardware, networking, etc.)
        (hostsDir + "/${hostname}")

        # Package profile management system
        ../profiles/packages/default.nix

        # User management system
        ../users

        # Custom modules
        ../modules/joke-motd

        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager

        # Profile and user configuration
        {
          packageProfiles.enable = finalProfiles;
          customUsers.users = finalUsers;
          home-manager = homeManagerConfig;
        }
      ]
      # Optional system information and debugging
        ++ lib.optional enableSystemInfo (systemInfo {
          inherit hostname system;
          profiles = finalProfiles;
          users = finalUsers;
        })
        # User-provided additional modules
        ++ extraModules;
    };
}
