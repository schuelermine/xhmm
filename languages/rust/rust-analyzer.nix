{ config, pkgs, lib, ... }:
let cfg = config.programs.rust.rust-analyzer;
in {
  options.programs.rust.rust-analyzer = {
    enable = lib.mkEnableOption "rust-analyzer, a Rust language server";
    package = lib.mkPackageOption pkgs "rust-analyzer" { };
  };
  config.home.packages = lib.mkIf cfg.enable [ cfg.package ];
}
