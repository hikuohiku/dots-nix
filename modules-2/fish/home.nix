{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.mymodule.apps.fish;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [

    # ── Common ────────────────────────────────────────────────────────
    {
      home.sessionVariables = {
        LS_COLORS = "$(vivid generate tokyonight-moon)";
      };
      home.packages = with pkgs; [
        grc
        vivid
      ];

      programs.fish = {
        enable = true;
        shellAbbrs = {
          ls = "eza --color=auto --icons";
          l = "eza --color=auto --icons -lah";
          ll = "eza --color=auto --icons -l";
          la = "eza --color=auto --icons -a";
          cat = "bat";
          find = "fd";
          grep = "rg";
          sed = "sd";
          top = "btop";
          du = "dua";
          rm = "gomi";
          c = "code";
          v = "nvim";
          vi = "nvim";
          vim = "nvim";
          n = "neovide";
          g = "git";
          lg = "lazygit";
          lspath = "echo $PATH | sed 's/ /\\n/g' | sort";
          ja = "trans -b :ja";
          cp = "cp -r";
          "-" = "prevd";
          "+" = "nextd";
          zl = "zellij a";
          tree = "eza --color=auto --icons -a --tree";
        };
        functions = {
          gitignore = "curl -sL https://www.gitignore.io/api/$argv";
          nr = "nix run nixpkgs#$argv[1] -- $argv[2..]";
          ssh = ''
            if test -n "$ZELLIJ"
                echo "Please detach zellij session before starting ssh connection."
            else
                command ssh $argv
            end
          '';
          mkenv = "cp ~/environments/$argv[1]/flake.nix ./flake.nix && echo 'use flake' > .envrc && direnv allow";
        };
        plugins = [
          {
            name = "z";
            src = pkgs.fishPlugins.z.src;
          }
          {
            name = "grc";
            src = pkgs.fishPlugins.grc.src;
          }
          {
            name = "fzf";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
          {
            name = "fish-ghq";
            src = inputs.fish-ghq;
          }
          {
            name = "fish-fzf-bd";
            src = inputs.fish-fzf-bd;
          }
        ];
        interactiveShellInit = ''
          bind ctrl-s '__ghq_repository_search'
          bind shift-tab complete
          bind tab '
            if commandline --search-field >/dev/null
              commandline -f complete
            else
              commandline -f complete-and-search
            end
          '
          fzf_configure_bindings --git_log= --git_status= --processes= --directory=ctrl-q
          complete -c uv -n '__fish_seen_subcommand_from remove' -xa '(yq -r ".project.dependencies[]" pyproject.toml)'
          complete -c ghq -n '__fish_seen_subcommand_from get' -xa "(gh repo list --json name,owner --jq '.[] | select(.owner.login==\"hikuohiku\") | .owner.login + \"/\" + .name' 2>/dev/null)"
          set -g fzf_fd_opts --no-ignore
          set PATH $HOME/.ghcup/bin $PATH
          set PATH /Library/TeX/texbin $PATH
          fish_add_path /Users/hikuo/.antigravity/antigravity/bin
        '';
      };

      programs.starship.enable = true;
    }

    # ── Darwin ────────────────────────────────────────────────────────
    (lib.mkIf isDarwin {
      programs.fish = {
        shellAbbrs = {
          copy = "pbcopy";
          paste = "pbpaste";
        };
        interactiveShellInit = ''
          fish_add_path /opt/homebrew/bin
        '';
      };
    })

    # ── Linux ─────────────────────────────────────────────────────────
    (lib.mkIf isLinux {
      programs.fish = {
        shellAbbrs = {
          copy = "wlcopy";
          paste = "wl-paste";
        };
        functions = {
          code = "command code $argv --enable-wayland-ime";
        };
        plugins = [
          {
            name = "done";
            src = pkgs.fishPlugins.done.src;
          }
        ];
      };
    })
  ]);
}
