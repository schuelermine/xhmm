{ pkgs, lib, ... }:
with builtins // lib;
let
  guard = q: x: if q then x else null;
  guardNull = x: guard (x != null);
  concatStrings = foldl' (c1: c2: c1 + c2) "";
  filterSplitSegments = str:
    concatLists
    (map (x: if isList x then x else if x == "" then [ ] else [ x ]) str);
  splitToChars = str: filterSplitSegments (split "" str);
  splitToWords = str: filterSplitSegments (split " " str);
  asChars = f: str: concatStrings (f (splitToChars str));
  capitalize = asChars (asHead toUpper);
  cons = x: xs: [ x ] ++ xs;
  asCons = f1: f2: xs: cons (f1 (head xs)) (f2 (tail xs));
  asHead = f: xs: cons (f (head xs)) (tail xs);
  asTail = asCons id;
  snakeCase = str:
    concatStringsSep "" (asTail (map capitalize) (splitToWords str));
  mkModule = { name, varName ? toUpper (head (split " " name))
    , optionName ? snakeCase name, example ? "nano", packageExample ? example }:
    { config, ... }:
    let
      cfg = config.home.${optionName};
      moduleType = submoduleWith {
        modules = [{
          options = {
            package = mkOption {
              type = with types; nullOr package;
              default = null;
              defaultText = literalExpression "null";
              example = literalExpression "pkgs.${packageExample}";
              description = ''
                Package providing the ${name}. This package will be installed to your profile.
                If <code>null</code> then the ${name} is assumed to already be available.
              '';
            };
            executable = mkOption {
              type = with types; nullOr (either str path);
              default = null;
              defaultText = literalExpression "null";
              example = literalExpression ''"${example}"'';
              description = "Executable of the ${name} within the package.";
            };
          };
        }];
      };
    in {
      options.home.${optionName} = mkOption {
        type = with types; nullOr (either str moduleType);
        default = null;
        description = ''
          The ${name} to use. This sets the <code>${varName}</code> variable.
          Can be a string or a submodule specifying a <code>package</code> and an <code>executable</code>.
        '';
      };
      config.home = {
        packages = mkIf (isAttrs cfg && cfg.package != null) [ cfg.package ];
        sessionVariables = {
          ${guardNull cfg varName} =
            if isString cfg then cfg else toString cfg.executable;
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
