{
  plugins.lsp = {
    enable = true;
    servers = {
      nixd.enable = true;
      lua_ls.enable = true;
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
      ts_ls.enable = true;
      pyright.enable = true;
      yamlls.enable = true;
      jsonls.enable = true;
    };
  };
}
