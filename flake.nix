{
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, nixpkgs, opam-nix }:
    let
      system = "x86_64-linux";
      # instantiate nixpkgs with this system
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (opam-nix.lib.${system}) buildOpamProject;
      package = "hello";
    in rec {
      packages.${system} = buildOpamProject { } package ./. {
        ocaml-base-compiler = "*";
        ocaml-lsp-server = "*";
      };
      defaultPackage.${system} = packages.${system}.${package};
      # create a development environment with ocaml-lsp-server
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ defaultPackage.${system} ];
        buildInputs = [ packages.${system}."ocaml-lsp-server" ];
      };
    };
}
