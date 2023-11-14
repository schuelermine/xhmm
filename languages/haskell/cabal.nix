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
        The contents of the `.cabal/config` file.
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
  config.home = lib.mkIf cfg.enable {
    packages = [ cfg.package ];
    file.".cabal/config" = lib.mkIf (cfg.config != null) { text = cfg.config; };
  };
}
