{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ which-key-nvim ];
    extraLuaConfig = ''
      local wk_ok, wk = pcall(require, 'which-key')
      if not wk_ok then return end

      wk.setup({
        plugins = { spelling = true },
        window = { border = 'rounded' },
        layout = { align = 'left' },
      })

      -- Telescope helpers (lazy load inside mappings)
      local tb = function(fn)
        return function()
          local ok, b = pcall(require, 'telescope.builtin')
          if ok and b[fn] then b[fn]() end
        end
      end

      -- Toggle helpers
      local function toggle(option, on_msg, off_msg)
        return function()
          vim.opt_local[option] = not vim.opt_local[option]:get()
          vim.notify((vim.opt_local[option]:get() and on_msg) or off_msg, vim.log.levels.INFO)
        end
      end
      local diagnostics_virtual_text = true
      local function toggle_diagnostics()
        diagnostics_virtual_text = not diagnostics_virtual_text
        vim.diagnostic.config({ virtual_text = diagnostics_virtual_text })
        vim.notify('Diagnostics virtual_text: ' .. tostring(diagnostics_virtual_text), vim.log.levels.INFO)
      end

      -- GitSigns helpers (only call if loaded)
      local function gs(fn)
        return function()
          local ok, g = pcall(require, 'gitsigns')
          if ok and g[fn] then g[fn]() end
        end
      end

      wk.register({
        ["<leader>"] = {
          f = {
            name = "+file",
            f = { tb('find_files'), 'Find Files' },
            r = { tb('oldfiles'), 'Recent Files' },
            g = { tb('live_grep'), 'Live Grep' },
            b = { tb('buffers'), 'Buffers' },
            h = { tb('help_tags'), 'Help' },
            n = { function() vim.cmd.enew() end, 'New File' },
            s = { function() vim.cmd.write() end, 'Save File' },
            S = { function() vim.cmd('%write') end, 'Save All' },
            q = { function() vim.cmd.quit() end, 'Quit' },
            Q = { function() vim.cmd('qa') end, 'Quit All' },
          },
          g = {
            name = "+git",
            s = { gs('stage_hunk'), 'Stage Hunk' },
            r = { gs('reset_hunk'), 'Reset Hunk' },
            R = { gs('reset_buffer'), 'Reset Buffer' },
            p = { gs('preview_hunk'), 'Preview Hunk' },
            b = { gs('toggle_current_line_blame'), 'Toggle Blame' },
            d = { gs('diffthis'), 'Diff This' },
            D = { function() gs('diffthis')('~') end, 'Diff This (HEAD~)' },
            n = { function() gs('nav_hunk')('next') end, 'Next Hunk' },
            N = { function() gs('nav_hunk')('prev') end, 'Prev Hunk' },
          },
          l = { name = "+lsp" }, -- keys already mapped in lsp module
          d = { name = "+debug" }, -- keys mapped in dap module
          t = {
            name = "+toggle",
            r = { toggle('relativenumber', 'Relative number ON', 'Relative number OFF'), 'Relativenumber' },
            n = { toggle('number', 'Number ON', 'Number OFF'), 'Line Numbers' },
            w = { toggle('wrap', 'Wrap ON', 'Wrap OFF'), 'Wrap' },
            s = { toggle('spell', 'Spell ON', 'Spell OFF'), 'Spell' },
            c = { function()
                    if vim.opt.colorcolumn:get()[1] then
                      vim.opt.colorcolumn = {}
                      vim.notify('ColorColumn OFF')
                    else
                      vim.opt.colorcolumn = { '80' }
                      vim.notify('ColorColumn 80')
                    end
                  end, 'ColorColumn 80' },
            d = { toggle_diagnostics, 'Diagnostics virtual text' },
          },
        },
      })
    '';
  };
}
