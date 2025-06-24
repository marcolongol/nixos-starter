{
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        numbers = "buffer_id";
        close_command = "bdelete! %d";
        right_mouse_command = "bdelete! %d";
        left_mouse_command = "buffer %d";
        middle_mouse_command = null;
        indicator = { style = "icon"; };
        buffer_close_icon = "󰅖";
        modified_icon = "●";
        close_icon = "";
        left_trunc_marker = "";
        right_trunc_marker = "";
        max_name_length = 30;
        max_prefix_length = 30;
        tab_size = 21;
        diagnostics = "nvim_lsp";
        diagnostics_update_in_insert = false;
        show_buffer_icons = true;
        show_buffer_close_icons = true;
        show_close_icon = true;
        show_tab_indicators = true;
        persist_buffer_sort = true;
        separator_style = "slant";
        enforce_regular_tabs = true;
        always_show_bufferline = true;
        sort_by = "id";
      };
    };
  };
}
