{ config, pkgs, lib, ... }:
with builtins // lib;
{
  options.programs.rust.rustc = {
    enable = mkEnableOption "rustc, the Rust compiler";
    package =
      mkPackageOption config.programs.rust.toolchainPackages "rustc" { };
  };
}
