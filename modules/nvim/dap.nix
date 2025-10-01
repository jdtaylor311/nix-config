{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ nvim-dap nvim-dap-ui nvim-nio ];
    extraLuaConfig = ''
      local dap = require('dap')
      local dapui = require('dapui')
      dapui.setup({})
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'DAP Continue' })
      vim.keymap.set('n', '<F1>', function() dap.step_into() end, { desc = 'DAP Step Into' })
      vim.keymap.set('n', '<F2>', function() dap.step_over() end, { desc = 'DAP Step Over' })
      vim.keymap.set('n', '<F3>', function() dap.step_out() end, { desc = 'DAP Step Out' })
      vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'DAP Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'DAP Set Breakpoint' })
    '';
  };
}
