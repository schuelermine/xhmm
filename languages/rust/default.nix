{ config, pkgs, lib, ... }:
let cfg = config.programs.rust;
in {
  imports = [
    ./cargo.nix
    ./clippy.nix
    ./expose-src-location.nix
    ./rls.nix
    ./rust-analyzer.nix
    ./rustc.nix
    ./rustfmt.nix
    ./rustup.nix
    ./custom-toolchain.nix
  ];
  options.programs.rust = {
    toolchainPackages = lib.mkOption {
      type = lib.types.raw;
      description = ''
        The Rust toolchain package set to use.
        This is used by the individual program modules' default package.
        It has no effect when a custom toolchain is used.
      '';
      default = pkgs.rust.packages.stable;
      defaultText = lib.literalExpression "pkgs.rust.packages.stable";
      example = lib.literalExpression "pkgs.rust.packages.prebuilt";
    };
    finalPackages = lib.mkOption {
      type = with lib.types; listOf package;
      internal = true;
      default = lib.optional cfg.cargo.enable cfg.cargo.package
        ++ lib.optional cfg.clippy.enable cfg.clippy.package
        ++ lib.optional cfg.rustc.enable cfg.rustc.package
        ++ lib.optional cfg.rustfmt.enable cfg.rustfmt.package;
    };
  };
  config = {
    assertions = [{
      assertion = !cfg.rustup.enable || !cfg.customToolchain.customEnabled;
      message = "Cannot activate rustup and custom toolchain at once";
    }];
    home.packages = cfg.finalPackages;
  };
}
