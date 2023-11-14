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
  };
  config.home.packages = lib.mkIf cfg.enable [ cfg.package ];
}
