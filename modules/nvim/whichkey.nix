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

      local function tb(fn)
        return function()
          local ok, b = pcall(require, 'telescope.builtin')
          if ok and b[fn] then b[fn]() end
        end
      end

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

      local function gs(fn)
        return function()
          local ok, g = pcall(require, 'gitsigns')
          if ok and g[fn] then g[fn]() end
        end
      end

      -- New spec: use wk.add with explicit mappings and group declarations
      wk.add({
        -- Group declarations
        { '<leader>f', group = '+file' },
        { '<leader>g', group = '+git' },
        { '<leader>l', group = '+lsp' },
        { '<leader>d', group = '+debug' },
        { '<leader>t', group = '+toggle' },

        -- File group
        { '<leader>ff', tb('find_files'), desc = 'Find Files' },
        { '<leader>fr', tb('oldfiles'), desc = 'Recent Files' },
        { '<leader>fg', tb('live_grep'), desc = 'Live Grep' },
        { '<leader>fb', tb('buffers'), desc = 'Buffers' },
        { '<leader>fh', tb('help_tags'), desc = 'Help' },
        { '<leader>fn', function() vim.cmd.enew() end, desc = 'New File' },
        { '<leader>fs', function() vim.cmd.write() end, desc = 'Save File' },
        { '<leader>fS', function() vim.cmd('%write') end, desc = 'Save All' },
        { '<leader>fq', function() vim.cmd.quit() end, desc = 'Quit' },
        { '<leader>fQ', function() vim.cmd('qa') end, desc = 'Quit All' },

        -- Git group
        { '<leader>gs', gs('stage_hunk'), desc = 'Stage Hunk' },
        { '<leader>gr', gs('reset_hunk'), desc = 'Reset Hunk' },
        { '<leader>gR', gs('reset_buffer'), desc = 'Reset Buffer' },
        { '<leader>gp', gs('preview_hunk'), desc = 'Preview Hunk' },
        { '<leader>gb', gs('toggle_current_line_blame'), desc = 'Toggle Blame' },
        { '<leader>gd', gs('diffthis'), desc = 'Diff This' },
        { '<leader>gD', function() gs('diffthis')('~') end, desc = 'Diff This (HEAD~)' },
        { '<leader>gn', function() gs('nav_hunk')('next') end, desc = 'Next Hunk' },
        { '<leader>gN', function() gs('nav_hunk')('prev') end, desc = 'Prev Hunk' },

        -- Toggle group
        { '<leader>tr', toggle('relativenumber', 'Relative number ON', 'Relative number OFF'), desc = 'Relativenumber' },
        { '<leader>tn', toggle('number', 'Number ON', 'Number OFF'), desc = 'Line Numbers' },
        { '<leader>tw', toggle('wrap', 'Wrap ON', 'Wrap OFF'), desc = 'Wrap' },
        { '<leader>ts', toggle('spell', 'Spell ON', 'Spell OFF'), desc = 'Spell' },
        { '<leader>tc', function()
            if vim.opt.colorcolumn:get()[1] then
              vim.opt.colorcolumn = {}
              vim.notify('ColorColumn OFF')
            else
              vim.opt.colorcolumn = { '80' }
              vim.notify('ColorColumn 80')
            end
          end, desc = 'ColorColumn 80' },
        { '<leader>td', toggle_diagnostics, desc = 'Diagnostics virtual text' },
      })
    '';
  };
}
