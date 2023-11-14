{ config, pkgs, lib, ... }:
let
  outerCfg = config.programs.rust;
  cfg = config.programs.rust.customToolchain;
  components = (if cfg.components == null then [ ] else cfg.components)
    ++ lib.optional outerCfg.cargo.enable "cargo"
    ++ lib.optional outerCfg.clippy.enable "clippy"
    ++ lib.optional outerCfg.rustc.enable "rustc"
    ++ lib.optional outerCfg.rustfmt.enable "rustfmt";
  toolchainBuilderStructuredArgs.toolchain =
    lib.optionalAttrs (cfg.channel != null) { inherit (cfg) channel; }
    // lib.optionalAttrs (components != [ ]) { inherit components; }
    // lib.optionalAttrs (cfg.targets != null) { inherit (cfg) targets; }
    // lib.optionalAttrs (cfg.targets != null) { inherit (cfg) targets; }
    // lib.optionalAttrs (cfg.profile != null) { inherit (cfg) profile; };
  toolchainBuilderArgs = if cfg.config == null then
    if cfg.format == "path" then
      "${toTOML toolchainBuilderStructuredArgs}"
    else
      toolchainBuilderStructuredArgs
  else if cfg.format == "path" then
    cfg.config
  else
    fromTOML (lib.readFile cfg.config);
  toolchain = if cfg.toolchainPackage == null then
    cfg.builder toolchainBuilderArgs
  else
    cfg.toolchainPackage;
  tomlFormat = pkgs.formats.toml { };
  toTOML = tomlFormat.generate "rust-toolchain";
in {
  options.programs.rust.customToolchain = {
    toolchainPackage = lib.mkOption {
      type = with lib.types; nullOr package;
      description = ''
        A toolchain package to install.
        Disables `programs.rust.customToolchain.builder`.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression "fenix.stable.toolchain";
    };
    builder = lib.mkOption {
      type = with lib.types; nullOr (functionTo raw);
      description = ''
        A custom toolchain builder that takes a TOML toolchain specification
        and returns a derivation to be installed. Set to `null` to disable.
        This takes either `programs.rust.customToolchain.config` or an
        attribute set composed of most other options there. Use
        `programs.rust.customToolchain.format` to specify how it should be passed.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression
        ''file: fenix.fromToolchainFile { inherit file; sha256 = "" }'';
    };
    format = lib.mkOption {
      type = lib.types.enum [ "attrs" "path" ];
      description = ''
        The format that `programs.rust.customToolchain.builder` takes its argument in.
        Can be either `"attrs"` or `"path"`.
      '';
      default = if cfg.config == null then "attrs" else "path";
      defaultText = lib.literalExpression ''"attrs"'';
      example = lib.literalExpression ''"path"'';
    };
    channel = lib.mkOption {
      type = with lib.types; nullOr str;
      description = ''
        `channel` field of TOML toolchain specification.
        Null to disable.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''"nightly-2020-07-10"'';
    };
    components = lib.mkOption {
      type = with lib.types; nullOr (listOf str);
      description = ''
        Extra elements for the `components` field of the TOML toolchain specification.
        Null to disable.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''[ "rustfmt" "rustc-dev" ]'';
    };
    targets = lib.mkOption {
      type = with lib.types; nullOr (listOf str);
      description = ''
        `targets` field of TOML toolchain specification.
        Null to disable.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression
        ''[ "wasm32-unknown-unknown" "thumbv2-none-eabi" ]'';
    };
    profile = lib.mkOption {
      type = with lib.types; enum [ "minimal" "default" "complete" ];
      description = ''
        The base toolchain profile.
        Can be `"minimal"`, `"default"`, or `"complete"`.
      '';
      default = "default";
      defaultText = lib.literalExpression ''"default"'';
      example = lib.literalExpression ''"minimal"'';
    };
    config = lib.mkOption {
      type = with lib.types; nullOr (either path str);
      description = ''
        The path to a `rust-toolchain.toml` or similar.
        Disables `programs.rust.customToolchain.profile` and `programs.rust.customToolchain.components`,
        and sets `programs.rust.customToolchain.format` to `"path"` (can be overridden).
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression "./rust-toolchain.toml";
    };
    customEnabled = lib.mkOption {
      type = with lib.types; bool;
      internal = true;
      default = cfg.builder != null || cfg.toolchainPackage != null;
    };
  };
  config.programs.rust.finalPackages =
    lib.mkIf (cfg.customEnabled) [ toolchain ];
}
