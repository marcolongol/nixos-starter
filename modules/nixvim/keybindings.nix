{
  keymaps = [
    # General keybindings
    {
      mode = "n";
      key = "<leader>h";
      action = "<cmd>nohlsearch<cr>";
      options.desc = "Clear search highlights";
    }
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd>w<cr>";
      options.desc = "Save file";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>q<cr>";
      options.desc = "Quit";
    }
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>qa<cr>";
      options.desc = "Quit all";
    }

    # File tree navigation
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>NvimTreeToggle<cr>";
      options.desc = "Toggle file tree";
    }
    {
      mode = "n";
      key = "<leader>o";
      action = "<cmd>NvimTreeFocus<cr>";
      options.desc = "Focus file tree";
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>NvimTreeFindFile<cr>";
      options.desc = "Find current file in tree";
    }

    # Buffer navigation
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options.desc = "Previous buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>BufferLineCycleNext<cr>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<leader>to";
      action = "<cmd>BufferLineCloseOthers<cr>";
      options.desc = "Close other buffers";
    }
    {
      mode = "n";
      key = "<leader>tc";
      action = "<cmd>BufferLinePickClose<cr>";
      options.desc = "Close picked buffer";
    }
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>BufferLinePick<cr>";
      options.desc = "Pick buffer";
    }
    {
      mode = "n";
      key = "<leader>c";
      action = "<cmd>BufferLineCloseLeft<cr>";
      options.desc = "Close current buffer";
    }

    # Telescope keybindings
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<cr>";
      options.desc = "Live grep";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<cr>";
      options.desc = "Find buffers";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>Telescope help_tags<cr>";
      options.desc = "Find help";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>Telescope oldfiles<cr>";
      options.desc = "Recent files";
    }

    # Window navigation (bonus keybindings)
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to bottom window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to top window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to right window";
    }

    # Copilot keybindings
    {
      mode = "i";
      key = "<C-g>";
      action = "<cmd>CopilotChat<cr>";
      options.desc = "Open Copilot chat";
    }

    # Lazygit keybinding
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<cr>";
      options.desc = "Open Lazygit";
    }
  ];
}
