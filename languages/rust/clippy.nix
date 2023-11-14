{ config, lib, ... }: {
  options.programs.rust.clippy = {
    enable = lib.mkEnableOption "clippy, the Rust linter";
    package =
      lib.mkPackageOption config.programs.rust.toolchainPackages "clippy" { };
  };
}
