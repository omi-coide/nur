{ mkDerivation, qtbase, wrapQtAppsHook, qmake, qttools, libGL, fetchFromGitHub, ... }:
mkDerivation {
  name = "test-app";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "omi-coide";
    repo = "app";
    rev = "1051fe150c38e3624cd790d27e59995992c1de99";
    fetchSubmodules = true;
    sha256 = "sha256-h/SK5py5T2bXTLllYSOSvE67Y9YDmjpOBCNTq8AJIKI=";
  };
  configurePhase = "qmake";
  buildPhase = "make";
  installPhase = "install -D app $out/bin/test-app";
  buildInputs = [qtbase qmake qttools libGL];
  nativeBuildInputs = [ wrapQtAppsHook ];
}

