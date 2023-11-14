{ config, lib, ... }: {
  options.programs.rust.rustc = {
    enable = lib.mkEnableOption "rustc, the Rust compiler";
    package =
      lib.mkPackageOption config.programs.rust.toolchainPackages "rustc" { };
  };
}
