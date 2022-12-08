{
  outputs = { self }: {
    homeManagerModules = {
      all = import ./.;
      languages = {
        all = import ./languages;
        haskell = import ./languages/haskell;
        python = import ./languages/python;
        rust = import ./languages/rust;
      };
      desktop = {
        all = import ./desktop;
        fonts = import ./desktop/fonts.nix;
        gnome = import ./desktop/gnome;
      };
      console = {
        all = import ./console;
        less = import ./console/less.nix;
        nano = import ./console/nano.nix;
        program-variables = import ./console/program-variables.nix;
        fish = import ./console/fish;
      };
    };
  };
}
