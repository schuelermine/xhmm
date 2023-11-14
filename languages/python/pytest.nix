{ config, lib, ... }:
let cfg = config.programs.python.pytest;
in {
  options.programs.python.pytest = {
    enable = lib.mkEnableOption "pytest";
    package =
      lib.mkPackageOption config.programs.python.pythonPackages "pytest" { };
  };
  config = {
    programs.python.packages = lib.mkIf cfg.enable (_: [ cfg.package ]);
  };
}
