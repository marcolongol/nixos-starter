{
  plugins.treesitter = {
    enable = true;
    settings = {
      nixGrammars = true;
      ensureInstalled = [
        "bash"
        "c"
        "cpp"
        "css"
        "html"
        "javascript"
        "json"
        "lua"
        "markdown"
        "nix"
        "python"
        "rust"
        "typescript"
        "tsx"
      ];
    };
  };
}
