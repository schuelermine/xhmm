{ config, lib, ... }:
with builtins // lib;
let
  selectAutostartDesktopFile = src:
    if isDerivation src then
      let
        desktopEntryPath = "${src}/share/desktop";
        desktopEntries = if pathExists desktopEntryPath then
          attrNames (readDir desktopEntryPath)
        else
          [ ];
        autostartEntryPath = "${src}/etc/xdg/autostart";
        autostartEntries = if pathExists autostartEntryPath then
          attrNames (readDir autostartEntryPath)
        else
          [ ];
        desktopSelection = selectDesktopEntry desktopEntries;
      in if length autostartEntries == 1 then
        "${src}/etc/xdg/autostart/${elemAt autostartEntries 0}"
      else if desktopSelection == null then
        throw
        "Could not uniquely determine an autostart desktop entry for ${src.name}"
      else
        "${src}/share/desktop/${desktopSelection}"
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
    type = with types; listOf (either package path);
    default = [ ];
    defaultText = literalExpression "[ ]";
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
  config.xdg.configFile = listToAttrs (map (src: {
    name = "autostart/${baseNameOf (selectAutostartDesktopFile src)}";
    value.source = selectAutostartDesktopFile src;
  }) config.xdg.autostart);
}
