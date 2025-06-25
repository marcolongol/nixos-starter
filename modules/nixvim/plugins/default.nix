{
  imports = [
    ./nvim-tree.nix
    ./telescope.nix
    ./lsp.nix
    ./schemastore.nix
    ./treesitter.nix
    ./bufferline.nix
    ./yanky.nix
    ./none-ls.nix
    ./trouble.nix
  ];

  plugins = {
    # Copilot
    copilot-vim.enable = true;
    copilot-chat.enable = true;

    # Lazygit
    lazygit.enable = true;

    # Status line
    lualine.enable = true;

    # Git integration
    gitsigns.enable = true;

    # Auto pairs
    nvim-autopairs.enable = true;

    # Web development icons
    web-devicons.enable = true;

    # Which-key
    which-key.enable = true;
  };
}
