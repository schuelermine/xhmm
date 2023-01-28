{ config, pkgs, lib, ... }:
with builtins // lib;
let
  cfg = config.programs.rust;
  cT = cfg.customToolchain;
  packages = if cT.builder == null && cT.toolchainPackage == null then
    optional cfg.cargo.enable cfg.cargo.package
    ++ optional cfg.clippy.enable cfg.clippy.package
    ++ optional cfg.rustc.enable cfg.rustc.package
    ++ optional cfg.rustfmt.enable cfg.rustfmt.package
  else
    [ toolchain ];
  toolchain =
    if cT.toolchainPackage == null then cT.builder toolchainArg else cT.toolchainPackage;
  toolchainArg = if cT.config != null then
    if cT.format == "path" then cT.config else fromTOML cT.config
  else if cT.format == "attrs" then
    toolchainConfig
  else
    toTOML toolchainConfig;
  toolchainConfig.toolchain = optionalAttrs (cT.channel != null) { inherit (cT) channel; } // optionalAttrs (components != [ ]) { inherit components; } // optionalAttrs (cT.targets != null) { inherit (cT) targets; } // optionalAttrs (cT.targets != null) { inherit (cT) targets; };
  components = (if cT.components == null then [ ] else cT.components) ++ declaredComponents;
  declaredComponents = optional cfg.cargo.enable "cargo"
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
