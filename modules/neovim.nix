{ config, pkgs, lib, ... }:
let
  inherit (pkgs) vimPlugins;
  # Pre-build treesitter grammars so no network access is needed at runtime.
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.bash
    p.c
    p.diff
    p.html
    p.lua
    p.markdown
    p.markdown_inline
    p.query
    p.vim
    p.vimdoc
    # Add more languages here as needed
  ]);
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;      # for some language servers / tools
    withPython3 = true;     # python plugins / servers

    # Install language servers & formatters DECLARATIVELY instead of using mason (runtime downloader).
    # Add more as you need (e.g. bash-language-server, typescript-language-server, rust-analyzer, etc.)
    extraPackages = with pkgs; [
      ripgrep fd git nodejs python3
      lua-language-server
      nil # Nix LSP (nil_ls)
      stylua
      alejandra
      shfmt
      prettierd
      black isort
    ];

    # Pure Nix managed plugins (NO lazy.nvim / packer). All pinned by flake.lock via nixpkgs rev.
    plugins = with vimPlugins; [
      which-key-nvim
      gitsigns-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      plenary-nvim
      nvim-web-devicons
      conform-nvim
      todo-comments-nvim
      mini-nvim
      treesitter
      nvim-autopairs
      indent-blankline-nvim
      nvim-lint
      neo-tree-nvim
      nui-nvim
      nvim-dap
      nvim-dap-ui
      nvim-nio
      nvim-lspconfig
      # Completion stack
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      luasnip
      friendly-snippets
      # GitHub Copilot integration
      copilot-lua
      copilot-cmp
      # Theme
      tokyonight-nvim
      # Optional helpers
      guess-indent-nvim
    ];

    # Inline Lua replacing old init.lua & plugin config. Keep minimal & focused.
    extraLuaConfig = builtins.readFile (pkgs.writeText "nvim-extra.lua" ''
      -- Leader
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '
      vim.g.have_nerd_font = false

      -- Core options
      local o = vim.o
      o.number = true
      o.mouse = 'a'
      o.showmode = false
      vim.schedule(function() o.clipboard = 'unnamedplus' end)
      o.breakindent = true
      o.undofile = true
      o.ignorecase = true
      o.smartcase = true
      o.signcolumn = 'yes'
      o.updatetime = 250
      o.timeoutlen = 300
      o.splitright = true
      o.splitbelow = true
      o.list = true
      vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
      o.expandtab = true
      o.tabstop = 2
      o.shiftwidth = 2
      o.softtabstop = 2
      o.smartindent = true
      o.inccommand = 'split'
      o.cursorline = true
      o.scrolloff = 10
      o.confirm = true

      -- Basic keymaps
      vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
      vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
      vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
      vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
      vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
      vim.keymap.set('n', '<C-k>', '<C-w><C-k>')

      -- Highlight on yank
      vim.api.nvim_create_autocmd('TextYankPost', {
        group = vim.api.nvim_create_augroup('pure-nix-highlight-yank', { clear = true }),
        callback = function() vim.hl.on_yank() end,
      })

      ------------------------------------------------------------------
      -- Colorscheme
      ------------------------------------------------------------------
      require('tokyonight').setup({ styles = { comments = { italic = false } } })
      vim.cmd.colorscheme('tokyonight-night')

      ------------------------------------------------------------------
      -- which-key (basic groups)
      ------------------------------------------------------------------
      local wk = require('which-key')
      wk.add({
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk' },
      })

      ------------------------------------------------------------------
      -- Telescope
      ------------------------------------------------------------------
      local telescope = require('telescope')
      telescope.setup({
        extensions = { ['ui-select'] = require('telescope.themes').get_dropdown() },
      })
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      local tb = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', tb.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sf', tb.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', tb.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sb', tb.buffers, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader>sd', tb.diagnostics, { desc = '[S]earch [D]iagnostics' })

      ------------------------------------------------------------------
      -- Treesitter (parsers pre-built via withPlugins)
      ------------------------------------------------------------------
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
        indent = { enable = true, disable = { 'ruby' } },
      })

      ------------------------------------------------------------------
      -- GitHub Copilot (copilot.lua + copilot-cmp)
      ------------------------------------------------------------------
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
          gitcommit = true,
          ["*"] = true,
        },
      })
      require('copilot_cmp').setup()

      ------------------------------------------------------------------
      -- Completion (nvim-cmp + luasnip)
      ------------------------------------------------------------------
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'copilot' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        }),
      })

      ------------------------------------------------------------------
      -- LSP (no mason; servers installed via Nix extraPackages)
      ------------------------------------------------------------------
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local on_attach = function(ev)
        local buf = ev.buf
        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
        end
        map('grn', vim.lsp.buf.rename, 'LSP: Rename')
        map('gra', vim.lsp.buf.code_action, 'LSP: Code Action')
        map('grd', vim.lsp.buf.definition, 'LSP: Goto Definition')
        map('grr', vim.lsp.buf.references, 'LSP: References')
        map('gri', vim.lsp.buf.implementation, 'LSP: Implementation')
        map('grt', vim.lsp.buf.type_definition, 'LSP: Type Definition')
        map('<leader>th', function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ buf = buf }), { bufnr = buf })
          end
        end, 'Toggle Inlay Hints')
      end

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = { Lua = { completion = { callSnippet = 'Replace' } } },
      })
      lspconfig.nil_ls.setup({ capabilities = capabilities, on_attach = on_attach })

      -- Diagnostics styling
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = { spacing = 2, source = 'if_many' },
      })

      ------------------------------------------------------------------
      -- Formatting (conform)
      ------------------------------------------------------------------
      require('conform').setup({
        notify_on_error = false,
        format_on_save = function(buf)
          local disable = { c = true, cpp = true }
          if disable[vim.bo[buf].filetype] then return end
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          nix = { 'alejandra' },
          sh = { 'shfmt' },
          javascript = { 'prettierd' },
          typescript = { 'prettierd' },
          json = { 'prettierd' },
          yaml = { 'prettierd' },
          markdown = { 'prettierd' },
        },
      })
      vim.keymap.set('n', '<leader>f', function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end, { desc = 'Format buffer' })

      ------------------------------------------------------------------
      -- Linting (nvim-lint) - example for markdown
      ------------------------------------------------------------------
      local lint = require('lint')
      lint.linters_by_ft = { markdown = { 'markdownlint' } }
      local lint_grp = vim.api.nvim_create_augroup('nix-pure-lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_grp,
        callback = function()
          if vim.bo.modifiable then lint.try_lint() end
        end,
      })

      ------------------------------------------------------------------
      -- Gitsigns
      ------------------------------------------------------------------
      require('gitsigns').setup({
        signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' } },
        on_attach = function(buf)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buf, desc = desc }) end
          map('n', ']c', function() if vim.wo.diff then vim.cmd.normal { ']c', bang = true } else gs.nav_hunk('next') end end, 'Next hunk')
          map('n', '[c', function() if vim.wo.diff then vim.cmd.normal { '[c', bang = true } else gs.nav_hunk('prev') end end, 'Prev hunk')
          map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
          map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
          map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
          map('n', '<leader>hb', gs.blame_line, 'Blame line')
        end,
      })

      ------------------------------------------------------------------
      -- Neo-tree
      ------------------------------------------------------------------
      vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { silent = true, desc = 'Neo-tree reveal' })
      require('neo-tree').setup({
        filesystem = { window = { mappings = { ['\\'] = 'close_window' } } },
      })

      ------------------------------------------------------------------
      -- mini.nvim (ai / surround / statusline)
      ------------------------------------------------------------------
      require('mini.ai').setup({ n_lines = 500 })
      require('mini.surround').setup()
      local statusline = require('mini.statusline')
      statusline.setup({ use_icons = vim.g.have_nerd_font })
      statusline.section_location = function() return '%2l:%-2v' end

      ------------------------------------------------------------------
      -- Autopairs
      ------------------------------------------------------------------
      require('nvim-autopairs').setup({})

      ------------------------------------------------------------------
      -- indent-blankline
      ------------------------------------------------------------------
      require('ibl').setup({})

      ------------------------------------------------------------------
      -- todo-comments
      ------------------------------------------------------------------
      require('todo-comments').setup({ signs = false })

      ------------------------------------------------------------------
      -- DAP (basic minimal config + UI)
      ------------------------------------------------------------------
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

      ------------------------------------------------------------------
      -- nvim-autopairs integrates with cmp automatically (for bracket pairing on confirm)
      ------------------------------------------------------------------
      local autopairs_cmp_ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
      if autopairs_cmp_ok then
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end

      ------------------------------------------------------------------
      -- Final message (can be removed)
      ------------------------------------------------------------------
      vim.defer_fn(function() vim.notify('Neovim (pure Nix) loaded', vim.log.levels.INFO) end, 20)
    '');
  };

  # IMPORTANT: You can now remove the old 'home/nvim' directory since config is generated.
  # Leaving it in place is harmless but unused.
  # (Do NOT set xdg.configFile."nvim" any more, that would override this inline config.)
}