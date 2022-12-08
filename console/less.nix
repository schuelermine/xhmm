{ config, pkgs, lib, ... }:
with lib;
let cfg = config.programs.less;
in {
  options.programs.less.options = mkOption {
    type = types.listOf types.str;
    description = ''
      The options passed to less. This sets the <code>$LESS</code> environment variable.
    '';
    default = [ ];
    example = ''[ "-R" ]'';
  };
  config = mkIf cfg.enable {
    home = {
      sessionVariables."LESS" = builtins.concatStringsSep " " cfg.options;
      pager = "${pkgs.less}/bin/less";
    };
  };
}
