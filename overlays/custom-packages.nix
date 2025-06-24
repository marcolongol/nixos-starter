# Custom packages overlay - add your own packages here
{ inputs }:

final: prev: {
  # Custom packages namespace
  custom = {
    # Example: A custom shell script package
    hello-world = prev.writeShellScriptBin "hello-world" ''
      echo "Hello from custom NixOS configuration!"
      echo "Built with flake inputs and overlays"
    '';

    # Example: Custom nixvim configuration 
    # You can create multiple nixvim configurations for different purposes
    myCustomNixVim = let nixvimModule = import ../modules/nixvim;
    in inputs.nixvim.legacyPackages.${final.system}.makeNixvimWithModule {
      module = nixvimModule;
    };
  };
}
