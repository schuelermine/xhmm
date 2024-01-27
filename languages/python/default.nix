{ config, pkgs, lib, ... }:
let cfg = config.programs.python;
in {
  imports = [ ./mypy.nix ./pip.nix ./pytest.nix ];
  options.programs.python = {
    versionName = lib.mkOption {
      type = with lib.types; nullOr str;
      apply = opt:
        if opt != null then lib.replaceStrings [ "." ] [ "" ] opt else null;
      description = ''
        The Python version to use.
        Setting this value automatically sets `programs.python.pythonPackages`.
        The value is automatically stripped of periods to match the nixpkgs naming convention.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''"311"'';
    };
    pythonPackages = lib.mkOption {
      type = lib.types.raw;
      description = "The Python package set to use.";
      default = if cfg.versionName != null then
        pkgs."python${cfg.versionName}Packages"
      else
        pkgs.python3Packages;
      defaultText = lib.literalExpression "pkgs.python3Packages";
      example = lib.literalExpression "pkgs.python311Packages";
    };
    enable = lib.mkEnableOption "the Python interpreter";
    package = lib.mkPackageOption cfg.pythonPackages "Python interpreter" {
      default = [ "python" ];
    } // {
      apply = pkg:
        if pkg ? withPackages then
          pkg.withPackages cfg.packages
        else
          lib.trace ''
            You have provided a package as programs.python.package that doesn't have the withPackages function.
            This disables specifying packages via programs.python.packages unless you manually install them.
          '';
    };
    packages = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      apply = x: if !lib.isFunction x then _: x else x;
      description = ''
        The Python packages to install for the Python interpreter.
      '';
      default = pkgs: [ ];
      defaultText = lib.literalExpression "pkgs: [ ]";
      example = lib.literalExpression "pkgs: [ pkgs.requests ]";
    };
    config = lib.mkOption {
      type = with lib.types; nullOr (either path lines);
      description = ''
        Python interpreter startup configuration. See
        <https://docs.python.org/3/using/cmdline.html#envvar-PYTHONSTARTUP>
        for details.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        import numpy as np
      '';
    };
    configPath = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Python interpreter startup configuration file path. See
        <https://docs.python.org/3/using/cmdline.html#envvar-PYTHONSTARTUP>
        for details.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''"${config.xdg.configHome}/startup.py"'';
    };
    historyPath = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Python interpreter history file path. See
        <https://docs.python.org/3.13/using/cmdline.html#envvar-PYTHON_HISTORY>
        for details.
        This option is only available in Python 3.13.
      '';
      default = null;
      defaultText = lib.literalExpression "null";
      example = lib.literalExpression ''
        "${config.xdg.stateHome}/python_history"
      '';
    };
    enableColors =
      lib.mkEnableOption ''
        colors in the interpreter. See
        <https://docs.python.org/3.13/using/cmdline.html#envvar-PYTHON_COLORS>
        for details.
        This option is only available in Python 3.13.
      ''
      // {default = true;};
  };
  config.home = {
    packages = lib.mkIf cfg.enable [cfg.package];
    sessionVariables = {
      PYTHONSTARTUP = with cfg;
        lib.mkIf (config != null && configPath != null) (toString configPath);
      PYTHON_HISTORY = lib.mkIf (cfg.historyPath != null) (toString cfg.historyPath);
      PYTHON_COLORS = if cfg.enableColors then "0" else "1";
    };
    file."${cfg.configPath}" = lib.mkIf (cfg.config != null) {
      source = if builtins.isPath cfg.config then
        cfg.config
      else
        pkgs.writeText "python/startup.py" ''
          # DO NOT EDIT -- this file has been generated automatically.
          # Python interpreter startup commands, generated via home-manager.

          ${cfg.config}
        '';
    };
  };
}
