{ config, pkgs, lib, ... }:
let cfg = config.programs.less;
in {
  options.programs.less.options = lib.mkOption {
    type = with lib.types; listOf str;
    description = ''
      The options passed to less. This sets the `$LESS` environment variable.
    '';
    default = [ ];
    example = ''[ "-R" ]'';
  };
  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables."LESS" = builtins.concatStringsSep " " cfg.options;
      pager = "${pkgs.less}/bin/less";
    };
  };
}
