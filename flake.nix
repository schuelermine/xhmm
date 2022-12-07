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
    };
  };
}
