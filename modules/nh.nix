{ types, ... }: {
  inputs = {
    mkWrapper.from = { parent }: parent.mkWrapper;
    nixpkgs.from = { parent }: parent.nixpkgs;
  };

  options = {
    environment = {
      type = types.attrs;
      description = ''
        Environment variables to be passed to the wrapped package.

        See the [documentation](https://github.com/nix-community/nh#environment-variables) for valid options.
      '';
    };

    package = {
      type = types.derivation;
      defaultFunc = { inputs }: inputs.nixpkgs.pkgs.nh;
      description = "The nh package to wrap.";
    };
  };

  impl =
    { options, inputs }:
    if options ? environment then
      inputs.mkWrapper {
        inherit (options) environment package;
      }
    else
      options.package;

  meta = {
    maintainers = [ "itsyunaya" ];
  };
}
