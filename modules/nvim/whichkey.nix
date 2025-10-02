{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [which-key-nvim];
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
            -- Inline NES Tab mapping (insert + normal) if sidekick present
            { '<Tab>', function()
                local ok, sk = pcall(require, 'sidekick')
                if ok and sk.nes_jump_or_apply and sk.nes_jump_or_apply() then
                  return ""
                end
                -- fallback: in insert mode keep Tab behavior
                return vim.api.nvim_get_mode().mode:match('i') and '\t' or ""
              end, mode = { 'i', 'n' }, expr = true, desc = 'Next Edit Suggestion' },
            -- Group declarations
            { '<leader>f', group = '+file' },
            { '<leader>g', group = '+git' },
            { '<leader>l', group = '+lsp' },
            { '<leader>d', group = '+debug' },
            { '<leader>t', group = '+toggle' },
    { '<leader>a', group = '+ai' },
      { '<leader>p', group = '+project' },
      { '<leader>T', group = '+theme' },
      { '<leader>q', group = '+quit' },
      { 'gsa', group = 'surround-add' },
      { 'gsd', group = 'surround-del' },
      { 'gsf', group = 'surround-find' },
      { 'gsF', group = 'surround-find-left' },
      { 'gsh', group = 'surround-highlight' },
      { 'gsr', group = 'surround-replace' },
      { 'gsn', group = 'surround-n-lines' },

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
      { '<leader>fA', '<cmd>FormatProject<CR>', desc = 'Format Project' },
      { '<leader>qq', function() vim.cmd('qa!') end, desc = 'Force Quit All' },

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

            -- Theme group (cycle / specific)
            { '<leader>Tc', function()
                local list = { 'everforest-dark', 'tokyonight-storm', 'catppuccin-mocha' }
                local current = vim.g.colors_name
                local idx = 1
                for i, name in ipairs(list) do if current == name then idx = i break end end
                local nextName = list[(idx % #list) + 1]
                pcall(vim.cmd.colorscheme, nextName)
                vim.notify('Theme -> ' .. nextName)
              end, desc = 'Cycle Theme' },
            { '<leader>Te', function() pcall(vim.cmd.colorscheme, 'everforest') end, desc = 'Everforest' },
            { '<leader>Tt', function() pcall(vim.cmd.colorscheme, 'tokyonight-storm') end, desc = 'TokyoNight Storm' },
            { '<leader>Tm', function() pcall(vim.cmd.colorscheme, 'catppuccin-mocha') end, desc = 'Catppuccin Mocha' },

            -- Project/session placeholder (can hook into future persistence plugin)
            { '<leader>ps', function() vim.notify('Session save (placeholder)') end, desc = 'Save Session' },
            { '<leader>pl', function() vim.notify('Session load (placeholder)') end, desc = 'Load Session' },

            -- LSP explicit exposures (mirroring on_attach so which-key shows them immediately)
            { '<leader>ln', function() vim.lsp.buf.rename() end, desc = 'LSP Rename' },
            { '<leader>la', function() vim.lsp.buf.code_action() end, desc = 'LSP Code Action' },
            { '<leader>ld', function() vim.lsp.buf.definition() end, desc = 'LSP Definition' },
            { '<leader>lD', function() vim.lsp.buf.declaration() end, desc = 'LSP Declaration' },
            { '<leader>li', function() vim.lsp.buf.implementation() end, desc = 'LSP Implementation' },
            { '<leader>lt', function() vim.lsp.buf.type_definition() end, desc = 'LSP Type Definition' },
            { '<leader>lR', function() vim.lsp.buf.references() end, desc = 'LSP References' },
            { '<leader>lh', function() vim.lsp.buf.hover() end, desc = 'LSP Hover' },
            { '<leader>ls', function() vim.lsp.buf.signature_help() end, desc = 'LSP Signature' },
      { '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, desc = 'LSP Format' },

            -- DAP extras
            { '<leader>de', function() require('dapui').eval() end, desc = 'DAP Eval' },
            { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'DAP REPL' },
            { '<leader>dx', function() require('dap').terminate() end, desc = 'DAP Terminate' },
            { '<leader>dl', function() require('dap').run_last() end, desc = 'DAP Run Last' },

            -- AI / Sidekick (CLI + prompts)
            { '<leader>aa', function() -- toggle/focus last tool
                local ok, cli = pcall(require, 'sidekick.cli')
                if ok then cli.toggle({ focus = true }) end
              end,
              desc = 'Sidekick Toggle CLI' },
            { '<leader>as', function() -- select a tool (installed or all)
                local ok, cli = pcall(require, 'sidekick.cli')
                if ok then cli.select() end
              end,
              desc = 'Sidekick Select CLI' },
            { '<leader>ap', function() -- select a prompt from library
                local ok, cli = pcall(require, 'sidekick.cli')
                if ok and cli.select_prompt then cli.select_prompt() elseif ok and cli.prompt then cli.prompt() end
              end,
              desc = 'Sidekick Prompt Picker' },
            { '<leader>ar', function() -- send review preset
                local ok, cli = pcall(require, 'sidekick.cli')
                if ok and cli.ask then cli.ask({ prompt = 'review', submit = true }) end
              end,
              desc = 'Sidekick Review Prompt' },
            { '<leader>ac', function() -- open Copilot CLI directly
                local ok, cli = pcall(require, 'sidekick.cli')
                if ok and cli.toggle then cli.toggle({ name = 'copilot', focus = true }) end
              end,
              desc = 'Sidekick Copilot CLI' },
            { '<leader>ax', function() -- ad-hoc freeform ask
                local ok, cli = pcall(require, 'sidekick.cli')
                if not ok or not cli.ask then return end
                vim.ui.input({ prompt = 'Sidekick ask: ' }, function(input)
                  if input and input ~= "" then
                    cli.ask({ msg = input, submit = true })
                  end
                end)
              end,
              desc = 'Sidekick Ask (Freeform)' },
          })
    '';
  };
}
