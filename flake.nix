{
  description = ''
    Max Wilson <dot> Dev
  '';

  inputs.nixpkgs.url = github:NixOS/nixpkgs/30d7b9341291dbe1e3361a5cca9052ee1437bc97;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux = 
      with import nixpkgs {
        system = "x86_64-linux";
      };
      let
        name = "maxwilson-dev";
      in
      stdenv.mkDerivation {
        inherit name;
        version = "0.1.0";

        src = builtins.path { 
          inherit name;
          path = ./.;
        };

        installPhase = ''
          mkdir $out
          cp -r $src/favicons $src/index.html $out
        '';
      };
  };
}
