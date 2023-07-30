{ config, pkgs, lib }:
with builtins // lib;
let
  src = config.xdg.autostart;
  desktopFile =
    if isDerivation src then
      let
        desktopEntries = attrNames (readDir "${src}/share/desktop");
        autostartEntries = attrNames (readDir "${src}/etc/xdg/autostart");
        desktopSelection = selectDesktopEntry desktopEntries;
      in if length autostartEntries == 1
      then "${src}/etc/xdg/autostart/${elemAt autostartEntries 0}"
      else "${src}/share/desktop/${desktopSelection}"
    else
      src;
  selectDesktopEntry = desktopEntries:
    let
      autostartNamed =
        filterAttrs (k: v: match ".*-autostart\\.desktop" != null);
      notAutostartNamed =
        filterAttrs (k: v: match ".*-autostart\\.desktop" == null);
    in if length autostartNamed == 1 then
      elemAt autostartNamed 0
    else if length autostartNamed == 0 && length notAutostartNamed == 1 then
      elemAt notAutostartNamed 0
    else
      null;
in {
  options.xdg.autostart = mkOption {
    type = with types; listOf (either package str);
    default = [ ];
    defaultTest = literalExpression "[ ]";
    example = literalExpression "[ pkgs.valent ]";
    description = ''
      List of packages or desktop entries that are autostarted.
      Tries to determine the autostart entry by the following heuristic:
      - If there is only one file in etc/xdg/autostart, use it
      - If there is no such file and only one file matching *-autostart.desktop in share/applications, use it
      - If there is only one desktop file in share/applications, use it
      If this heuristic fails to identify only one desktop file, you can pass the path to the desktop file directly.
    '';
  };
  config.xdg.configFile."autostart/${desktopFile}".source = desktopFile;
}
