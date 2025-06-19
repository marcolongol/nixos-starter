{
  imports = [ ./options.nix ./keybindings.nix ./plugins ];

  enableMan = true;

  nixpkgs = {
    config = {
      useGlobalPkgs = true;
      allowUnfree = true;
    };
  };

  extraConfigLua = ''
    require('telescope').load_extension('lazygit')
  '';
}
