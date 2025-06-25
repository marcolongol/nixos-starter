{ lib, ... }: {
  # vim.lsp
  lsp = {
    inlayHints.enable = true;
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gD";
        lspBufAction = "references";
      }
      {
        key = "gt";
        lspBufAction = "type_definition";
      }
      {
        key = "gi";
        lspBufAction = "implementation";
      }
      {
        key = "K";
        lspBufAction = "hover";
      }
      {
        action =
          lib.nixvim.mkRaw
            "function() vim.diagnostic.jump({ count=-1, float=true }) end";
        key = "<leader>k";
      }
      {
        action =
          lib.nixvim.mkRaw
            "function() vim.diagnostic.jump({ count=1, float=true }) end";
        key = "<leader>j";
      }
      {
        action = "<CMD>LspStop<Enter>";
        key = "<leader>lx";
      }
      {
        action = "<CMD>LspStart<Enter>";
        key = "<leader>ls";
      }
      {
        action = "<CMD>LspRestart<Enter>";
        key = "<leader>lr";
      }
      {
        action =
          lib.nixvim.mkRaw "require('telescope.builtin').lsp_definitions";
        key = "gd";
      }
    ];
  };
  # tiny-inline-diagnostics
  # plugins.tiny-inline-diagnostic = {
  #   enable = true;
  #   settings = {
  #     preset = "modern";
  #     multilines = {
  #       enabled = true;
  #       max_lines = 3;
  #     };
  #     options = {
  #       use_icons_from_diagnostic = true;
  #       show_source = {
  #         enabled = true;
  #         if_many = true;
  #       };
  #     };
  #   };
  # };
  # lspkind
  plugins.lspkind = { enable = true; };
  # lsp-format
  plugins.lsp-format = { enable = true; };
  # nvim-lsp
  plugins.lsp = {
    enable = true;
    inlayHints = true;
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
