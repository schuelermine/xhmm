{ config, pkgs, lib, ... }:
let
  cfg = config.programs.rust.cargo;
  tomlFormat = pkgs.formats.toml { };
in {
  options.programs.rust.cargo = {
    enable = lib.mkEnableOption "cargo, the Rust build system";
    package =
      lib.mkPackageOption config.programs.rust.toolchainPackages "cargo" { };
    settings = lib.mkOption {
      type = lib.types.nullOr tomlFormat.type;
      description = ''
        Configuration written to `$HOME/.cargo/config.toml`.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        {
          cargo-new.vcs = "pijul";
        }
      '';
    };
  };
  config.home = lib.mkIf cfg.enable {
    file.".cargo/config.toml" = lib.mkIf (cfg.settings != null) {
      source = tomlFormat.generate "cargo-config" cfg.settings;
    };
  };
}
