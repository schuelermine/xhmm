{ config, pkgs, lib, ... }:
with builtins // lib;
{
  options.programs.rust.clippy = {
    enable = mkEnableOption "clippy, the Rust linter";
    package =
      mkPackageOption config.programs.rust.toolchainPackages "clippy" { };
  };
}
