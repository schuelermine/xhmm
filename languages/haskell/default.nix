{ config, pkgs, lib, ... }:
let
  cfg = config.programs.haskell;
  compactV = lib.replaceStrings [ "." ] [ "" ];
in {
  imports = [ ./cabal.nix ./ghc.nix ./ghcup.nix ./hls.nix ./stack.nix ];
  options.programs.haskell = {
    ghcVersionName = lib.mkOption {
      type = with lib.types; nullOr str;
      apply = opt: if opt != null then compactV opt else null;
      description = ''
        The GHC version to use.
        Setting this value automatically sets `programs.haskell.haskellPackages`.
        The value is automatically stripped of periods to match the nixpkgs naming convention.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''"942"'';
    };
    effectiveGhcVersionName = lib.mkOption {
      type = lib.types.str;
      internal = true;
      default = if cfg.ghcVersionName != null then
        cfg.ghcVersionName
      else
        compactV cfg.haskellPackages.ghc.version;
    };
    haskellPackages = lib.mkOption {
      type = lib.types.raw;
      description = "The Haskell package set to use.";
      default = if cfg.ghcVersionName != null then
        pkgs.haskell.packages."ghc${cfg.ghcVersionName}"
      else
        pkgs.haskellPackages;
      defaultText = lib.literalExpression "pkgs.haskellPackages";
      example = lib.literalExpression "pkgs.haskell.packages.ghc923";
    };
  };
}
