{ config, pkgs, lib, ... }:
with lib; {
  options.programs.fish.prompt = mkOption {
    type = types.str;
    default = null;
    example = ''
      echo \$
    '';
    description = "Function body for fish_prompt";
  };
  config.programs.fish.functions = mkIf (config.programs.fish.prompt != null) {
    fish_prompt = config.programs.fish.prompt;
  };
}
