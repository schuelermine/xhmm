{ config, pkgs, lib, ... }:
with lib; {
  options.fonts.fonts = mkOption {
    type = types.listOf types.package;
    default = [ ];
    defaultText = literalExpression "[ ]";
    example = literalExpression "[ pkgs.atkinson-hyperlegible ]";
    description = ''
      List of fonts to be available in the user environment.
    '';
  };
  config.home.packages = mkIf config.fonts.fontconfig.enable config.fonts.fonts;
}
