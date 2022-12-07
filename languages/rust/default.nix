{ config, pkgs, lib, ... }:
with builtins // lib;
{
  imports = [
    ./cargo.nix
    ./clippy.nix
    ./expose-src-location.nix
    ./rls.nix
    ./rust-analyzer.nix
    ./rustc.nix
    ./rustfmt.nix
    ./rustup.nix
  ];
  options.programs.rust.toolchainPackages = mkOption {
    type = types.raw;
    description = "The Rust toolchain package set to use";
    default = pkgs.rust.packages.stable;
    defaultText = literalExpression "pkgs.rust.packages.stable";
    example = literalExpression "pkgs.rust.packages.prebuilt";
  };
}
