{ config, pkgs, lib, ... }:
let
  cfg = config.programs.haskell.stack;
  yamlFormat = pkgs.formats.yaml { };
in {
  options.programs.haskell.stack = {
    enable = lib.mkEnableOption "the Haskell Tool Stack";
    package = lib.mkPackageOption pkgs "Stack" { default = [ "stack" ]; };
    settings = lib.mkOption {
      type = lib.types.nullOr yamlFormat.type;
      description = ''
        Configuration written to `.stack/config.yaml`.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        {
          color = "never";
        }
      '';
    };
  };
  config.home = lib.mkIf cfg.enable {
    packages = lib.mkIf cfg.enable [ cfg.package ];
    file.".stack/config.yaml" = lib.mkIf (cfg.settings != null) {
      source = yamlFormat.generate "stack-config" cfg.settings;
    };
  };
}
