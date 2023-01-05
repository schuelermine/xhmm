{ config, pkgs, lib, ... }:
with builtins // lib;
let
  cfg = config.programs.haskell.hls;
  warning = ''
    You have provided a package as programs.haskell.language-server.package that doesn't allow overriding supportedGhcPackages.
    This disables specifying supported GHC versions via programs.haskell.hls.extraSupportedGhcVersions.
    It is recommended to use pkgs.haskell-language-server or a derivative, not a HLS from haskellPackages or similar.
  '';
in {
  options.programs.haskell.hls = {
    enable = mkEnableOption "the Haskell Language Server";
    package =
      mkPackageOption pkgs "HLS" { default = [ "haskell-language-server" ]; }
      // {
        apply = pkg:
          if pkg ? override.__functionArgs.supportedGhcVersions then
            pkg.override {
              supportedGhcVersions =
                [ config.programs.haskell.effectiveGhcVersionName ]
                ++ cfg.extraSupportedGhcVersions;
            }
          else
            trace warning pkg;
      };
    extraSupportedGhcVersions = mkOption {
      type = with types; listOf str;
      description = "The GHC Versions to support with HLS.";
      default = [ ];
      defaultText = literalExpression "[ ]";
      example = literalExpression ''[ "902" ]'';
    };
  };
  config.home.packages = mkIf cfg.enable [ cfg.package ];
}
