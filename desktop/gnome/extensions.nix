{ config, pkgs, lib, ... }:
with builtins // lib;
let cfg = config.gnome.extensions;
in {
  options.gnome.extensions = {
    enable = mkEnableOption "GNOME shell extensions" // {
      default = length cfg.enabledExtensions != 0;
    };
    enabledExtensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      defaultText = literalExpression "[ ]";
      example = literalExpression "[ pkgs.gnomeExtensions.appindicator ]";
      description =
        "List of packages that provide extensions that are to be enabled.";
    };
    extraExtensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      defaultText = literalExpression "[ ]";
      description = "Extra extension packages to install (but not enable).";
    };
  };
  config = {
    dconf.settings."org/gnome/shell" = {
      disable-user-extensions = !cfg.enable;
      enabled-extensions = map (pkg: pkg.extensionUuid) cfg.enabledExtensions;
    };
    home.packages = cfg.enabledExtensions ++ cfg.extraExtensions;
  };
}
