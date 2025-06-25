{
  imports = [ ./options.nix ./keybindings.nix ./plugins ];

  enableMan = true;

  nixpkgs = {
    config = {
      useGlobalPkgs = true;
      allowUnfree = true;
    };
  };
}
