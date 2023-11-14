{ config, pkgs, lib, ... }:
let
  cfg = config.programs.python.pip;
  iniFormat = pkgs.formats.ini { };
in {
  options.programs.python.pip = {
    enable = lib.mkEnableOption "pip";
    package =
      lib.mkPackageOption config.programs.python.pythonPackages "pip" { };
    settings = lib.mkOption {
      type = lib.types.nullOr iniFormat.type;
      description = ''
        Configuration written to `$XDG_CONFIG_HOME/pip/pip.conf`.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        {
          global.timeout = 60;
        }
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    programs.python.packages = (_: [ cfg.package ]);
    xdg.configFile."pip/pip.conf" = lib.mkIf (cfg.settings != null) {
      source = iniFormat.generate "pip-config" cfg.settings;
    };
  };
}
