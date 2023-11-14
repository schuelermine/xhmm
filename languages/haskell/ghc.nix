{ config, lib, ... }:
let cfg = config.programs.haskell.ghc;
in {
  options.programs.haskell.ghc = {
    enable = lib.mkEnableOption
      "the Glorious Glasgow Haskell Compilation System (GHC, the compiler)";
    package =
      lib.mkPackageOption config.programs.haskell.haskellPackages "GHC" {
        default = [ "ghc" ];
      } // {
        apply = pkg:
          if pkg ? withPackages then
            pkg.withPackages cfg.packages
          else
            lib.trace ''
              You have provided a package as programs.haskell.ghc.package that doesn't have the withPackages function.
              This disables specifying packages via programs.haskell.ghc.packages unless you manually install them.
            '' pkg;
      };
    packages = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      apply = x: if !lib.isFunction x then _: x else x;
      description = ''
        The Haskell packages to install for GHC.
        This installs the packages for GHC only, not in your actual user profile.
      '';
      default = hkgs: [ ];
      defaultText = lib.literalExpression "hkgs: [ ]";
      example = lib.literalExpression "hkgs: [ hkgs.primes ]";
    };
    ghciConfig = lib.mkOption {
      type = with lib.types; nullOr lines;
      description = ''
        The contents of the `.ghci` file.
        If set to `null`, no file will be generated.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        '''
          :set +s
        '''
      '';
    };
  };
  config.home = lib.mkIf cfg.enable {
    packages = [ cfg.package ];
    file.".ghci" = lib.mkIf (cfg.ghciConfig != null) { text = cfg.ghciConfig; };
  };
}
