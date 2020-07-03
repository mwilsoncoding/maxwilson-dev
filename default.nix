{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7db146538e49ad4bee4b5c4fea073c38586df7e2.tar.gz") {} }:

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