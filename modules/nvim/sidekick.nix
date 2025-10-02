{ pkgs, lib, ... }:
let
  sidekickPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = "sidekick.nvim";
    version = "2025-10-01"; # date of inclusion
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "sidekick.nvim";
      rev = "6f0616359540fcbfa5cf2ae88cbdf2a028331a86"; # pinned commit
      sha256 = "0xgv90bi3l2059n2zwhadhylwljhba5q2mgv335knlzz8ljcd2f7"; # obtained via nix-prefetch-url --unpack
    };
    # Upstream currently references sidekick.docs during its internal require check.
    # Disable the neovim runtime require check (doCheck=false) to avoid build failure.
    doCheck = false;
    meta = { homepage = "https://github.com/folke/sidekick.nvim"; }; 
  };

in {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ plenary-nvim nui-nvim sidekickPlugin ];
    extraLuaConfig = ''
      -- Sidekick setup
      local ok, sidekick = pcall(require, 'sidekick')
      if ok then
        sidekick.setup({
          providers = {
            -- Example OpenAI provider; ensure env var exported
            openai = {
              api_key = os.getenv('OPENAI_API_KEY'),
              model = 'gpt-4o-mini',
            },
          },
          ui = {
            border = 'rounded',
          },
          -- Prefer Copilot CLI/LSP as default tool when toggling (assumption; adjust if upstream option differs)
          cli = {
            default = 'copilot',
          },
        })
      end
    '';
  };
}
