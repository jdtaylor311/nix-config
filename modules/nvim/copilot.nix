{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      copilot-lua
      copilot-cmp
    ];
    extraLuaConfig = ''
      -- GitHub Copilot core setup
      local ok_copilot, copilot = pcall(require, 'copilot')
      if ok_copilot then
        copilot.setup({
          suggestion = { enabled = false }, -- we'll use cmp source instead of inline ghost text
          panel = { enabled = false },
          filetypes = { -- disable for some filetypes by default; adjust as you like
            markdown = true,
            help = true,
            gitcommit = true,
          },
        })
      end

      -- Integrate Copilot with nvim-cmp
      local ok_cmp, cmp = pcall(require, 'cmp')
      if ok_cmp then
        local ok_cop_src, _ = pcall(require, 'copilot_cmp')
        if ok_cop_src then
          require('copilot_cmp').setup()
          -- If cmp already initialized we can safely insert copilot source with lower priority
          local existing = cmp.get_config()
          local new_sources = cmp.config.sources({ { name = 'copilot', group_index = 2 } })
          -- merge while keeping previous sources
          local merged = {}
          for _, s in ipairs(existing.sources or {}) do table.insert(merged, s) end
          for _, s in ipairs(new_sources) do table.insert(merged, s) end
          cmp.setup({ sources = merged })
        end
      end
    '';
  };
}
