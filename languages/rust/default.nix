{ config, pkgs, lib, ... }:
with builtins // lib;
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
    toolchainPackages = mkOption {
      type = types.raw;
      description = ''
        The Rust toolchain package set to use.
        This is used by the individual program modules' default package.
        It has no effect when a custom toolchain is used.
      '';
      default = pkgs.rust.packages.stable;
      defaultText = literalExpression "pkgs.rust.packages.stable";
      example = literalExpression "pkgs.rust.packages.prebuilt";
    };
    finalPackages = mkOption {
      type = types.listOf types.package;
      internal = true;
      default = optional cfg.cargo.enable cfg.cargo.package
        ++ optional cfg.clippy.enable cfg.clippy.package
        ++ optional cfg.rustc.enable cfg.rustc.package
        ++ optional cfg.rustfmt.enable cfg.rustfmt.package;
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
