{ config, pkgs, lib, ... }:
let cfg = config.programs.nano;
in {
  options.programs.nano = {
    enable = lib.mkEnableOption "nano";
    package = lib.mkPackageOption pkgs "nano" { };
    config = lib.mkOption {
      type = with lib.types; nullOr lines;
      description = ''
        The contents of the `.nanorc` file.
        If set to `null`, no file will be generated.
      '';
      default = "";
      example = ''"set atblanks"'';
    };
  };
  config = lib.mkMerge [
    {
      home = lib.mkIf cfg.enable {
        packages = [ cfg.package ];
        editor = "${cfg.package}/bin/nano";
      };
    }
    { home.file.".nanorc".text = cfg.config; }
  ];
}
