{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7db146538e49ad4bee4b5c4fea073c38586df7e2.tar.gz") {} }:

pkgs.stdenv.mkDerivation {
  name = "maxwilson-dev";
  version = "0.0.1";

  src = path { path = ./.; name = "maxwilson-dev"; };

  installPhase = ''
    cp -r $src $out
  '';
}
