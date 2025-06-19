# Package overrides overlay - modify existing nixpkgs packages
{ inputs ? { } }:

final: prev: {
  # Example: Override a package to use a different version
  # hello = prev.hello.overrideAttrs (old: {
  #   version = "custom";
  # });

  # Example: Override neovim to use our custom nixvim configuration
  # Uncomment this if you want to replace the default neovim system-wide
  neovim = final.custom.myCustomNixVim;

  # Example: Add custom patches to packages
  # somePackage = prev.somePackage.overrideAttrs (old: {
  #   patches = (old.patches or []) ++ [
  #     ./patches/custom-patch.patch
  #   ];
  # });

  # Example: Override package with different build options
  # tmux = prev.tmux.override {
  #   withSystemd = true;
  # };
}
