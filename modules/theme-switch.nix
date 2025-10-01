{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myThemes;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  options.myThemes = {
    enable = lib.mkEnableOption "Enable custom theming integration" // {default = true;};
    neovimTransparent = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Make Neovim background transparent (terminal drives bg).";
    };
    autoSwitch = {
      enable = lib.mkEnableOption "Enable time-based theme switching" // {default = true;};
      dayTheme = lib.mkOption {
        type = lib.types.str;
        default = "everforest-dark";
        description = "Theme label used during day hours.";
      };
      nightTheme = lib.mkOption {
        type = lib.types.str;
        default = "everforest-dark";
        description = "Theme label used during night hours.";
      };
      dayStart = lib.mkOption {
        type = lib.types.int;
        default = 7;
        description = "Hour (0-23) when day theme becomes active.";
      };
      nightStart = lib.mkOption {
        type = lib.types.int;
        default = 19;
        description = "Hour (0-23) when night theme becomes active.";
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    script = pkgs.writeShellApplication {
      name = "sync-theme";
      text = ''
                #!/usr/bin/env bash
                set -euo pipefail
                H=$(date +%H)
                day_start=${toString cfg.autoSwitch.dayStart}
                night_start=${toString cfg.autoSwitch.nightStart}
                day_theme="${cfg.autoSwitch.dayTheme}"
                night_theme="${cfg.autoSwitch.nightTheme}"

                # Decide theme label
                chosen=$night_theme
                if [ "$H" -ge "$day_start" ] && [ "$H" -lt "$night_start" ]; then
                  chosen=$day_theme
                fi

                ghostty_dir="$HOME/.config/ghostty"
                mkdir -p "$ghostty_dir"
                # Map logical theme to palette file
                case "$chosen" in
                  everforest-dark) target="themes/everforest-dark" ;;
                  tokyonight-storm) target="themes/tokyonight-storm" ;;
                  catppuccin-mocha) target="themes/catppuccin-mocha" ;;
                  *) target="themes/everforest-dark" ;;
                esac
                ln -sf "$ghostty_dir/$target" "$ghostty_dir/current-theme"

                # Neovim dynamic theme loader
                nvim_lua_dir="$HOME/.config/nvim/lua"
                mkdir -p "$nvim_lua_dir"
                nvim_theme_file="$nvim_lua_dir/theme_dynamic.lua"
                case "$chosen" in
                  everforest-dark)
                    cat > "$nvim_theme_file" <<'EOF'
        vim.g.everforest_background = 'hard'
        vim.g.everforest_transparent_background = 1
        pcall(vim.cmd.colorscheme, 'everforest')
        EOF
                    ;;
                  tokyonight-storm)
                    cat > "$nvim_theme_file" <<'EOF'
        pcall(function()
          require('tokyonight').setup({ style = 'storm', transparent = true, styles = { comments = { italic = false } } })
        end)
        pcall(vim.cmd.colorscheme, 'tokyonight-storm')
        EOF
                    ;;
                  catppuccin-mocha)
                    cat > "$nvim_theme_file" <<'EOF'
        pcall(function()
          require('catppuccin').setup({ flavour = 'mocha', transparent_background = true })
        end)
        pcall(vim.cmd.colorscheme, 'catppuccin-mocha')
        EOF
                    ;;
                esac
      '';
    };
  in {
    home.packages = [script];

    # Initial run at activation so user gets the correct theme immediately.
    home.activation.syncThemeInitial = lib.mkIf cfg.autoSwitch.enable (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "[sync-theme] running initial theme sync" >&2
        "${script}/bin/sync-theme" || true
      ''
    );

    # Linux/systemd variant
    systemd.user = lib.mkIf (cfg.autoSwitch.enable && !isDarwin) {
      services.sync-theme = {
        Unit.Description = "Sync terminal + neovim theme";
        Service = {
          ExecStart = "${script}/bin/sync-theme";
          Type = "oneshot";
        };
      };
      timers.sync-theme = {
        Unit.Description = "Run sync-theme periodically";
        Timer = {
          OnBootSec = "1m";
          OnUnitActiveSec = "30m";
          Persistent = true;
        };
        Install.WantedBy = ["timers.target"];
      };
    };

    # macOS / launchd variant
    launchd.agents.sync-theme = lib.mkIf (cfg.autoSwitch.enable && isDarwin) {
      enable = true;
      config = {
        Label = "com.user.sync-theme";
        ProgramArguments = ["${script}/bin/sync-theme"];
        StartInterval = 1800; # 30 minutes
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/sync-theme.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/sync-theme.err.log";
      };
    };
  });
}
