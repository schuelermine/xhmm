{ config, lib, ... }:
let cfg = config.programs.rust.rls;
in {
  options.programs.rust.rls = {
    enable = lib.mkEnableOption "rls, a Rust language server";
    package =
      lib.mkPackageOption config.programs.rust.toolchainPackages "rls" { };
  };
  config.home.packages = lib.mkIf cfg.enable [ cfg.package ];
}
