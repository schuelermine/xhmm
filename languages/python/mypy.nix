{ config, pkgs, lib, ... }:
let
  cfg = config.programs.python.mypy;
  iniFormat = pkgs.formats.ini { };
in {
  options.programs.python.mypy = {
    enable = lib.mkEnableOption "mypy";
    package = lib.mkPackageOption pkgs "mypy" { };
    settings = lib.mkOption {
      type = lib.types.nullOr iniFormat.type;
      description = ''
        Configuration written to `$XDG_CONFIG_HOME/mypy/config`.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        {
          mypy.strict = true;
        }
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
    xdg.configFile."mypy/config" = lib.mkIf (cfg.settings != null) {
      source = iniFormat.generate "mypy-config" cfg.settings;
    };
  };
}
