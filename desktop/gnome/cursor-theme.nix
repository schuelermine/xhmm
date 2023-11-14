{ config, lib, ... }:
let cfg = config.gnome.cursorTheme;
in {
  options.gnome.cursorTheme = lib.mkOption {
    description = ''
      The cursor theme to use.
    '';
    type = with lib.types;
      nullOr (submoduleWith {
        modules = [{
          options = {
            package = mkOption {
              type = with types; nullOr package;
              default = null;
              defaultText = literalExpression "null";
              example = literalExpression "pkgs.yaru-theme";
              description = ''
                Package providing the cursor theme. This package will be installed to your profile.
                If `null` then the cursor theme is assumed to already be available.
              '';
            };
            name = mkOption {
              type = with types; str;
              default = "Adwaita";
              defaultText = literalExpression ''"Adwaita"'';
              example = literalExpression ''"Yaru"'';
              description = "Name of the cursor theme within the package.";
            };
          };
        }];
      });
    default = null;
  };
  config = lib.mkIf (cfg != null) {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];
    dconf.settings."org/gnome/desktop/interface".cursor-theme =
      lib.mkIf (cfg.name != "") cfg.name;
  };
}
