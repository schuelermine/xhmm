{ config, pkgs, lib, ... }:
let cfg = config.programs.haskell.cabal;
in {
  options.programs.haskell.cabal = {
    enable = lib.mkEnableOption "the Haskell Cabal (build system)";
    package =
      lib.mkPackageOption pkgs "Cabal" { default = [ "cabal-install" ]; };
    config = lib.mkOption {
      type = with lib.types; nullOr lines;
      description = ''
        The contents of the `$XDG_CONFIG_HOME/cabal/config` file.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        '''
          executable-stripping: True
        '''
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."cabal/config" = lib.mkIf (cfg.config != null) { text = cfg.config; };
  };
}
