{ config, pkgs, lib, ... }:
with builtins // lib;
let cfg = config.programs.rust;
in {
  options.programs.rust.exposeRustSrcLocation = mkOption {
    type = with types; nullOr (either bool path);
    apply = x:
      if isBool x then
        if x then
          "${config.programs.rust.toolchainPackages.rustPlatform.rustLibSrc}"
        else
          null
      else
        x;
    description = ''
      Expose the rust library source code via the <code>RUST_SRC_PATH</code> variable.
      If set to null, the variable remains unset.
      If set to true, use the value <code>config.programs.rust.toolchainPackages.rustPlatform.rustLibSrc</code>.
    '';
    default = null;
    defaultText = literalExpression "null";
    example = literalExpression
      ''"''${config.programs.rust.toolchainPackages.rustPlatform.rustLibSrc}"'';
  };
  config.home.sessionVariables = mkIf (cfg.exposeRustSrcLocation != null) {
    "RUST_SRC_PATH" = cfg.exposeRustSrcLocation;
  };
}
