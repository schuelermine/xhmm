{ lib, ... }:
let
  guard = q: x: if q then x else null;
  guardNull = x: guard (x != null);
  concatStrings = lib.foldl' (c1: c2: c1 + c2) "";
  filterSplitSegments = str:
    lib.concatLists
    (map (x: if lib.isList x then x else if x == "" then [ ] else [ x ]) str);
  splitToChars = str: filterSplitSegments (builtins.split "" str);
  splitToWords = str: filterSplitSegments (builtins.split " " str);
  asChars = f: str: concatStrings (f (splitToChars str));
  capitalize = asChars (asHead lib.toUpper);
  cons = x: xs: [ x ] ++ xs;
  asCons = f1: f2: xs: cons (f1 (lib.head xs)) (f2 (lib.tail xs));
  asHead = f: xs: cons (f (lib.head xs)) (lib.tail xs);
  asTail = asCons lib.id;
  snakeCase = str:
    lib.concatStringsSep "" (asTail (map capitalize) (splitToWords str));
  mkModule = { name, varName ? lib.toUpper (lib.head (builtins.split " " name))
    , optionName ? snakeCase name, example ? "nano", packageExample ? example }:
    { config, ... }:
    let
      cfg = config.home.${optionName};
      moduleType = lib.submoduleWith {
        modules = [{
          options = {
            package = lib.mkOption {
              type = with lib.types; nullOr package;
              default = null;
              defaultText = lib.literalExpression "null";
              example = lib.literalExpression "pkgs.${packageExample}";
              description = ''
                Package providing the ${name}. This package will be installed to your profile.
                If `null` then the ${name} is assumed to already be available.
              '';
            };
            executable = lib.mkOption {
              type = with lib.types; nullOr (either str path);
              default = null;
              defaultText = lib.literalExpression "null";
              example = lib.literalExpression ''"${example}"'';
              description = "Executable of the ${name} within the package.";
            };
          };
        }];
      };
    in {
      options.home.${optionName} = lib.mkOption {
        type = with lib.types; nullOr (either str moduleType);
        default = null;
        description = ''
          The ${name} to use. This sets the `${varName}` variable.
          Can be a string or a submodule specifying a `package` and an `executable`.
        '';
      };
      config.home = {
        packages =
          lib.mkIf (lib.isAttrs cfg && cfg.package != null) [ cfg.package ];
        sessionVariables = {
          ${guardNull cfg varName} =
            if lib.isString cfg then cfg else toString cfg.executable;
        };
      };
    };
in {
  imports = map mkModule [
    { name = "editor"; }
    { name = "visual editor"; }
    {
      name = "pager";
      example = "most";
    }
  ];
}
