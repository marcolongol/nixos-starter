{
  globals.mapleader = " ";

  # Editor options
  opts = {
    # Line numbers
    number = true;
    relativenumber = true;

    # Cursor line highlighting
    cursorline = true;
    cursorcolumn = false;

    # Indentation
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    autoindent = true;
    smartindent = true;

    # Search
    ignorecase = true;
    smartcase = true;
    hlsearch = true;
    incsearch = true;

    # UI improvements
    termguicolors = true;
    signcolumn = "yes";
    wrap = false;
    scrolloff = 8;
    sidescrolloff = 8;

    # Split behavior
    splitbelow = true;
    splitright = true;

    # Other useful options
    mouse = "a";
    clipboard = "unnamedplus";
    undofile = true;
    swapfile = false;
    backup = false;
    updatetime = 250;
    timeoutlen = 300;
  };

  colorschemes.oxocarbon = {
    enable = true;
  };
}
