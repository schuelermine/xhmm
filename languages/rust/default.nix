{ config, pkgs, lib, ... }:
with builtins // lib;
let
  cfg = config.programs.rust;
  cT = cfg.customToolchain;
  packages = if cT.builder == null then
    optional cfg.cargo.enable cfg.cargo.package
    ++ optional cfg.clippy.enable cfg.clippy.package
    ++ optional cfg.rustc.enable cfg.rustc.package
    ++ optional cfg.rustfmt.enable cfg.rustfmt.package
  else
    [ toolchain ];
  toolchain =
    if cT.toolchain != null then cT.builder toolchainArg else cT.toolchain;
  toolchainArg = if cT.config != null then
    if cT.format == "path" then cT.config else fromTOML cT.config
  else if cT.format == "attrs" then
    toolchainConfig
  else
    toTOML toolchainConfig;
  toolchainConfig.toolchain =
    optionalAttrs (cT.channel != null) { inherit (cT) channel; }
    // optionalAttrs (cT.components != null || components != [ ]) {
      components = cT.components ++ components;
    } // optionalAttrs (cT.targets != null) { inherit (cT) targets; }
    // optionalAttrs (cT.profile != null) { inherit (cT) targets; };
  components = optional cfg.cargo.enable "cargo"
    ++ optional cfg.clippy.enable "clippy" ++ optional cfg.rustc.enable "rustc"
    ++ optional cfg.rustfmt.enable "rustfmt";
  tomlFormat = pkgs.formats.toml { };
  toTOML = tomlFormat.generate "rust-toolchain";
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
  options.programs.rust.toolchainPackages = mkOption {
    type = types.raw;
    description = "The Rust toolchain package set to use";
    default = pkgs.rust.packages.stable;
    defaultText = literalExpression "pkgs.rust.packages.stable";
    example = literalExpression "pkgs.rust.packages.prebuilt";
  };
  config.home = { inherit packages; };
}
