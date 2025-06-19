{ hostsDir, inputs, ... }:

let
  lib = inputs.nixpkgs.lib.extend
    (final: prev: { customLib = import ./lib { lib = final; }; });
in {
  mkSystem = { system ? "x86_64-linux", hostname, profiles ? [ "common" ]
    , users ? [ ], extraModules ? [ ] }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        (hostsDir + "/${hostname}") # configuration.nix
        ../profiles/packages/default.nix
        ../users
        {
          packageProfiles.enable = profiles;
          customUsers.users = users;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = ".bak";
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ] ++ extraModules;
    };
}
