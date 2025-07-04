# This file is a modified version of the official Home Manager zellij module.
# Original source: https://github.com/nix-community/home-manager/blob/master/modules/programs/zellij.nix

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.my-zellij;
  yamlFormat = pkgs.formats.yaml { };
  zellijCmd = getExe cfg.package;

in
{
  meta.maintainers = [ hm.maintainers.mainrs ];

  options.programs.my-zellij = {
    enable = mkEnableOption "my-zellij";

    package = mkOption {
      type = types.package;
      default = pkgs.zellij;
      defaultText = literalExpression "pkgs.zellij";
      description = ''
        The zellij package to install.
      '';
    };

    settings = mkOption {
      type = yamlFormat.type;
      default = { };
      example = literalExpression ''
        {
          theme = "custom";
          themes.custom.fg = "#ffffff";
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/zellij/config.kdl`.

        If `programs.zellij.package.version` is older than 0.32.0, then
        the configuration is written to {file}`$XDG_CONFIG_HOME/zellij/config.yaml`.

        See <https://zellij.dev/documentation> for the full
        list of options.
      '';
    };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Zellij switched from yaml to KDL in version 0.32.0:
    # https://github.com/zellij-org/zellij/releases/tag/v0.32.0
    xdg.configFile."zellij/config.yaml" =
      mkIf (cfg.settings != { } && (versionOlder cfg.package.version "0.32.0"))
        {
          source = yamlFormat.generate "zellij.yaml" cfg.settings;
        };

    xdg.configFile."zellij/config.kdl" =
      mkIf (cfg.settings != { } && (versionAtLeast cfg.package.version "0.32.0"))
        {
          text = lib.hm.generators.toKDL { } cfg.settings;
        };

    programs.bash.initExtra = mkIf cfg.enableBashIntegration (
      mkOrder 200 ''
        eval "$(${zellijCmd} setup --generate-auto-start bash)"
      ''
    );

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration (
      mkOrder 200 ''
        eval "$(${zellijCmd} setup --generate-auto-start zsh)"
      ''
    );

    # programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration
    #   (mkOrder 200 ''
    #     eval (${zellijCmd} setup --generate-auto-start fish | string collect)
    #   '');
    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration (
      mkOrder 200 ''
        if test "$TERM" = "alacritty"
          eval (${zellijCmd} setup --generate-auto-start fish | sed 's/^\( *\)zellij attach -c$/\1zellij attach -c general/' | string collect)
        end
      ''
    );
  };
}
