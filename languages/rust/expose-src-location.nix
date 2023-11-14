{ config, lib, ... }:
let cfg = config.programs.rust;
in {
  options.programs.rust.exposeRustSrcLocation = lib.mkOption {
    type = with lib.types; nullOr (either bool path);
    apply = x:
      if lib.isBool x then
        if x then
          "${config.programs.rust.toolchainPackages.rustPlatform.rustLibSrc}"
        else
          null
      else
        x;
    description = ''
      Expose the rust library source code via the `RUST_SRC_PATH` variable.
      If set to null, the variable remains unset.
      If set to true, use the value `config.programs.rust.toolchainPackages.rustPlatform.rustLibSrc`.
    '';
    default = null;
    defaultText = lib.literalExpression "null";
    example = lib.literalExpression
      ''"''${config.programs.rust.toolchainPackages.rustPlatform.rustLibSrc}"'';
  };
  config.home.sessionVariables = lib.mkIf (cfg.exposeRustSrcLocation != null) {
    "RUST_SRC_PATH" = cfg.exposeRustSrcLocation;
  };
}
