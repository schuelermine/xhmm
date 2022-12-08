{ config, pkgs, lib, ... }:
with builtins // lib;
let cfg = config.gnome;
in {
  imports = [
    (mkAliasOptionModule [ "gnome" "gtkAppTheme" ] [ "gtk" "theme" ])
    (mkAliasOptionModule [ "gnome" "gtkIconTheme" ] [ "gtk" "iconTheme" ])
  ];
  options.gnome.shellTheme = mkOption {
    description = ''
      The custom shell theme to use.
    '';
    type = with types;
      nullOr (submoduleWith {
        modules = [{
          options = {
            package = mkOption {
              type = with types; nullOr package;
              default = null;
              defaultText = literalExpression "null";
              example = literalExpression "pkgs.yaru-theme";
              description = ''
                Package providing the custom shell theme. This package will be installed to your profile.
                If <code>null</code> then the custom shell theme is assumed to already be available.
              '';
            };
            name = mkOption {
              type = with types; str;
              default = "Adwaita";
              defaultText = literalExpression ''"Adwaita"'';
              example = literalExpression ''"Yaru"'';
              description = "Name of the custom shell theme within the package.";
            };
          };
        }];
      });
    default = null;
  };
  config = mkMerge [
    (mkIf (cfg.shellTheme != null) {
      home.packages = mkIf (cfg.shellTheme.package != null) [ cfg.shellTheme.package ];
      gnome.extensions.enabledExtensions = [ pkgs.gnomeExtensions.user-themes ];
      dconf.settings."org/gnome/shell/extensions/user-theme".name =
        cfg.shellTheme.name;
    })
    (mkIf (cfg.gtkAppTheme != null || cfg.gtkIconTheme != null) {
      gtk.enable = true;
    })
  ];
}
