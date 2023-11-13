{ config, pkgs, lib, ... }:
with builtins // lib;
let
  outerCfg = config.programs.rust;
  cfg = config.programs.rust.customToolchain;
  components = (if cfg.components == null then [ ] else cfg.components)
    ++ optional outerCfg.cargo.enable "cargo"
    ++ optional outerCfg.clippy.enable "clippy"
    ++ optional outerCfg.rustc.enable "rustc"
    ++ optional outerCfg.rustfmt.enable "rustfmt";
  toolchainBuilderStructuredArgs.toolchain =
    optionalAttrs (cfg.channel != null) { inherit (cfg) channel; }
    // optionalAttrs (components != [ ]) { inherit components; }
    // optionalAttrs (cfg.targets != null) { inherit (cfg) targets; }
    // optionalAttrs (cfg.targets != null) { inherit (cfg) targets; }
    // optionalAttrs (cfg.profile != null) { inherit (cfg) profile; };
  toolchainBuilderArgs = if cfg.config == null then
    if cfg.format == "path" then
      "${toTOML toolchainBuilderStructuredArgs}"
    else
      toolchainBuilderStructuredArgs
  else if cfg.format == "path" then
    cfg.config
  else
    fromTOML (readFile cfg.config);
  toolchain = if cfg.toolchainPackage == null then
    cfg.builder toolchainBuilderArgs
  else
    cfg.toolchainPackage;
  tomlFormat = pkgs.formats.toml { };
  toTOML = tomlFormat.generate "rust-toolchain";
in {
  options.programs.rust.customToolchain = {
    toolchainPackage = mkOption {
      type = with types; nullOr package;
      description = ''
        A toolchain package to install.
        Disables <code>programs.rust.customToolchain.builder</code>.
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression "fenix.stable.toolchain";
    };
    builder = mkOption {
      type = with types; nullOr (functionTo raw);
      description = ''
        A custom toolchain builder that takes a TOML toolchain specification
        and returns a derivation to be installed. Set to <code>null</code> to disable.
        This takes either <code>programs.rust.customToolchain.config</code> or an
        attribute set composed of most other options there. Use
        <code>programs.rust.customToolchain.format</code> to specify how it should be passed.
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression
        ''file: fenix.fromToolchainFile { inherit file; sha256 = "" }'';
    };
    format = mkOption {
      type = types.enum [ "attrs" "path" ];
      description = ''
        The format that <code>programs.rust.customToolchain.builder</code> takes its argument in.
        Can be either <code>"attrs"</code> or <code>"path"</code>.
      '';
      default = if cfg.config == null then "attrs" else "path";
      defaultText = literalExpression ''"attrs"'';
      example = literalExpression ''"path"'';
    };
    channel = mkOption {
      type = with types; nullOr str;
      description = ''
        <code>channel</code> field of TOML toolchain specification.
        Null to disable.
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression ''"nightly-2020-07-10"'';
    };
    components = mkOption {
      type = with types; nullOr (listOf str);
      description = ''
        Extra elements for the <code>components</code> field of the TOML toolchain specification.
        Null to disable.
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression ''[ "rustfmt" "rustc-dev" ]'';
    };
    targets = mkOption {
      type = with types; nullOr (listOf str);
      description = ''
        <code>targets</code> field of TOML toolchain specification.
        Null to disable.
      '';
      default = null;
      defaultText = literalExpression "null";
      example =
        literalExpression ''[ "wasm32-unknown-unknown" "thumbv2-none-eabi" ]'';
    };
    profile = mkOption {
      type = with types; enum [ "minimal" "default" "complete" ];
      description = ''
        The base toolchain profile.
        Can be <code>"minimal"</code>, <code>"default"</code>, or <code>"complete"</code>.
      '';
      default = "default";
      defaultText = literalExpression ''"default"'';
      example = literalExpression ''"minimal"'';
    };
    config = mkOption {
      type = with types; nullOr (either path str);
      description = ''
        The path to a <code>rust-toolchain.toml</code> or similar.
        Disables <code>programs.rust.customToolchain.profile</code> and <code>programs.rust.customToolchain.components</code>,
        and sets <code>programs.rust.customToolchain.format</code> to <code>"path"</code> (can be overridden).
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression "./rust-toolchain.toml";
    };
    customEnabled = mkOption {
      type = with types; bool;
      internal = true;
      default = cfg.builder != null || cfg.toolchainPackage != null;
    };
  };
  config.programs.rust.finalPackages = mkIf (cfg.customEnabled) [ toolchain ];
}
