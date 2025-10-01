-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- 1) Core Copilot client
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = { 'Copilot' },
    opts = {
      panel = { enabled = true },
      suggestion = { enabled = true }, -- handled by copilot-cmp instead of ghost text
      filetypes = {
        markdown = true,
        help = true,
        gitcommit = true,
        ['*'] = true,
      },
    },
  },

  -- 2) Bridge Copilot -> nvim-cmp
  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'zbirenbaum/copilot.lua' },
    event = 'InsertEnter',
    config = function()
      require('copilot_cmp').setup()
    end,
  },

  -- 3) Tell nvim-cmp about Copilot (and make it high priority)
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'zbirenbaum/copilot-cmp' },
    opts = function(_, opts)
      -- Insert Copilot source first so it ranks highly
      opts.sources = opts.sources or {}
      local has_copilot = false
      for _, s in ipairs(opts.sources) do
        if s.name == 'copilot' then
          has_copilot = true
        end
      end
      if not has_copilot then
        table.insert(opts.sources, 1, { name = 'copilot', group_index = 1, priority = 150 })
      end

      -- Nice label + keep ghost_text from cmp (distinct from Copilot ghosting)
      opts.formatting = opts.formatting or {}
      local orig_format = opts.formatting.format
      opts.formatting.format = function(entry, vim_item)
        if entry.source.name == 'copilot' then
          vim_item.kind = '' -- a little lightning flair
          vim_item.menu = '[COPILOT]'
        end
        if orig_format then
          return orig_format(entry, vim_item)
        end
        return vim_item
      end

      -- Optional: enable cmp ghost text (subtle inline hint from cmp, not Copilot)
      opts.experimental = opts.experimental or {}
      opts.experimental.ghost_text = opts.experimental.ghost_text ~= false

      return opts
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main', -- or "main" if stable
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- core Copilot
      { 'nvim-lua/plenary.nvim' }, -- required utility
    },
    opts = {
      debug = false,
      window = {
        layout = 'float', -- 'split' also works
        width = 0.8,
        height = 0.8,
      },
    },
    keys = {
      {
        '<leader>cc',
        '<cmd>CopilotChat<cr>',
        desc = 'Open Copilot Chat',
      },
      {
        '<leader>ce',
        '<cmd>CopilotChatExplain<cr>',
        desc = 'Explain current code',
      },
      {
        '<leader>cf',
        '<cmd>CopilotChatFix<cr>',
        desc = 'Fix selected code',
      },
    },
  },
  { 'tpope/vim-fugitive' },
}
