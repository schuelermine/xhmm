{ config, lib, ... }:
let cfg = config.gnome.extensions;
in {
  options.gnome.extensions = {
    enable = lib.mkEnableOption "GNOME shell extensions" // {
      default = lib.length cfg.enabledExtensions != 0;
    };
    enabledExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      defaultText = lib.literalExpression "[ ]";
      example = lib.literalExpression "[ pkgs.gnomeExtensions.appindicator ]";
      description =
        "List of packages that provide extensions that are to be enabled.";
    };
    extraExtensions = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      defaultText = lib.literalExpression "[ ]";
      description = "Extra extension packages to install (but not enable).";
    };
  };
  config = {
    dconf.settings = lib.mkIf cfg.enable {
      "org/gnome/shell" = {
        disable-user-extensions = !cfg.enable;
        enabled-extensions = map (pkg: pkg.extensionUuid) cfg.enabledExtensions;
      };
    };
    home.packages = cfg.enabledExtensions ++ cfg.extraExtensions;
  };
}
