{ config, pkgs, lib, ... }:
let cfg = config.programs.haskell.ghcup;
in {
  options.programs.haskell.ghcup = {
    enable = lib.mkEnableOption "ghcup, the Haskell toolchain installer";
    package = lib.mkPackageOption pkgs "ghcup" { };
  };
  config.home.packages = lib.mkIf cfg.enable [ cfg.package ];
}
