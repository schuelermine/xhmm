{ config, pkgs, lib, ... }:
let cfg = config.programs.rust.rustup;
in {
  options.programs.rust.rustup = {
    enable = lib.mkEnableOption "rustup, the Rust toolchain installer";
    package = lib.mkPackageOption pkgs "rustup" { };
  };
  config.programs.rust.finalPackages = lib.mkIf cfg.enable [ cfg.package ];
}
