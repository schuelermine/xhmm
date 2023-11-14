{ config, lib, ... }: {
  options.programs.fish.prompt = lib.mkOption {
    type = lib.types.str;
    default = null;
    example = ''
      echo \$
    '';
    description = "Function body for `fish_prompt`";
  };
  config.programs.fish.functions =
    lib.mkIf (config.programs.fish.prompt != null) {
      fish_prompt = config.programs.fish.prompt;
    };
}
