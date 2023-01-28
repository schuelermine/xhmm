{ config, pkgs, lib, ... }:
with builtins // lib;
let cfg = config.programs.rust.customToolchain;
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
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression ''file: fenix.fromToolchainFile { inherit file; sha256 = "" }'';
    };
    format = mkOption {
      type = types.enum [ "attrs" "path" ];
      description = ''
        The format that <code>programs.rust.customToolchainBuilder</code> takes its argument in.
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
      example = literalExpression ''[ "wasm32-unknown-unknown" "thumbv2-none-eabi" ]'';
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
      type = with types; nullOr path;
      description = ''
        The path to a <code>rust-toolchain.toml</code> or similar.
        Disables <code>programs.rust.customToolchain.profile</code> and <code>programs.rust.customToolchain.components</code>,
        and sets <code>programs.rust.customToolchain.format</code> to <code>"path"</code>.
      '';
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression "./rust-toolchain.toml";
    };
  };
}
