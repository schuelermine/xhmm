{ config, pkgs, lib, ... }:
with lib;
let cfg = config.programs.nano;
in {
  options.programs.nano = {
    enable = mkEnableOption "nano";
    package = mkPackageOption pkgs "nano" { };
    config = mkOption {
      type = with types; nullOr lines;
      description = ''
        The contents of the <code>.nanorc</code> file.
        If set to <code>null</code>, no file will be generated.
      '';
      default = "";
      example = ''"set atblanks"'';
    };
  };
  config.home = mkIf cfg.enable {
    packages = [ cfg.package ];
    file.".nanorc" = mkIf (cfg.config != null) { text = cfg.config; };
    editor = "${cfg.package}/bin/nano";
  };
}
