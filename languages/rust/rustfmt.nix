{ config, pkgs, lib, ... }:
let
  cfg = config.programs.rust.rustfmt;
  tomlFormat = pkgs.formats.toml { };
in {
  options.programs.rust.rustfmt = {
    enable = lib.mkEnableOption "rustfmt, the Rust formatter";
    package =
      lib.mkPackageOption config.programs.rust.toolchainPackages "rustfmt" { };
    settings = lib.mkOption {
      type = lib.types.nullOr tomlFormat.type;
      description = ''
        Configuration written to `$XDG_CONFIG_HOME/rustfmt/rustfmt.toml`.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        {
          indent_style = "Block";
          reorder_imports = false;
        }
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."rustfmt/rustfmt.toml" = lib.mkIf (cfg.settings != null) {
      source = tomlFormat.generate "rustfmt-config" cfg.settings;
    };
  };
}
