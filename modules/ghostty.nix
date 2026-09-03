{ types, ... }: {
  inputs = {
    mkWrapper.from = { parent }: parent.mkWrapper;
    nixpkgs.from = { parent }: parent.nixpkgs;
  };

  options = {
    settings = {
      type = types.attrs;
      description = ''
        Settings to be injected into the wrapped package's `config.ghostty`.

        See the [documentation](https://ghostty.org/docs/config) on valid options.

        Disjoint with the `configFile` option.
      '';
    };
    configFile = {
      type = types.pathLike;
      description = ''
        `config.ghostty` to be injected into the wrapped package.

        See the [documentation](https://ghostty.org/docs/config) on valid options.

        Disjoint with the `settings` option.
      '';
    };

    package = {
      type = types.derivation;
      defaultFunc = { inputs }: inputs.nixpkgs.pkgs.ghostty;
      description = "The ghostty package to be wrapped.";
    };
  };

  mutations."/fish".interactiveShellInit =
    { options }:
    "source ${options.package.shell_integration}/fish/vendor_conf.d/ghostty-shell-integration.fish";

  impl =
    { options, inputs }:
    let
      inherit (inputs.nixpkgs.pkgs) formats;
      # Duplicate keys are useful here, e.g. for the `palette` option
      generator = formats.keyValue { listsAsDuplicateKeys = true; };
    in
    assert options ? settings != options ? configFile;
    inputs.mkWrapper {
      inherit (options) package;
      symlinks = {
        "$out/ghostty/config.ghostty" =
          if options ? configFile then
            options.configFile
          else
            generator.generate "$out/ghostty/config.ghostty" options.settings;
      };

      environment = {
        XDG_CONFIG_HOME = "$out";
      };
    };

  meta = {
    maintainers = [ "itsyunaya" ];
  };
}
