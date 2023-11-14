{ config, lib, ... }: {
  options.fonts.fonts = lib.mkOption {
    type = with lib.types; listOf package;
    default = [ ];
    defaultText = lib.literalExpression "[ ]";
    example = lib.literalExpression "[ pkgs.atkinson-hyperlegible ]";
    description = ''
      List of fonts to be available in the user environment.
    '';
  };
  config.home.packages =
    lib.mkIf config.fonts.fontconfig.enable config.fonts.fonts;
}
