{
  outputs =
    { nixpkgs, ... }:
    let
      # Set the Erlang version
      erlangVersion = "erlang_28";
      # Set the Elixir version
      elixirVersion = "elixir_1_20";

      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [
                (
                  final: _:
                  let
                    erlang = final.beam.interpreters.${erlangVersion};
                    beamPackages = final.beam.packages.${erlangVersion};
                    elixir = beamPackages.${elixirVersion};
                  in
                  {
                    inherit erlang elixir;
                    inherit (beamPackages) elixir-ls hex;
                  }
                )
              ];
            }
          )
        );
    in
    {
      # packages = eachSystem (pkgs:
      # );

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            erlang
            elixir
            elixir-ls
          ];
        };
      });
    };
}
