{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/30d7b9341291dbe1e3361a5cca9052ee1437bc97.tar.gz") {} }:

pkgs.stdenv.mkDerivation {
  name = "maxwilson-dev";
  version = "0.1.0";

  src = builtins.path { 
    path = ./.;
    name = "maxwilson-dev";
  };

  installPhase = ''
    mkdir $out
    cp -r $src/favicons $src/index.html $out
  '';
}
