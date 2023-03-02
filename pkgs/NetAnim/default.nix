{ stdenv, qtbase, wrapQtAppsHook, qmake, qttools, libGL, fetchhg, gcc12, ... }:
stdenv.mkDerivation {
  name = "NetAnim";
  version = "1.0";
  src = fetchhg {
    url = "https://code.nsnam.org/netanim/";
    rev = "7b4d3db98f92";
    sha256 = "sha256-xT1xpgr2v91i0tEEWMr4SLGYsAVnyTDg+PmBhQuDko0=";
  };
  configurePhase = "qmake NetAnim.pro";
  buildPhase = "make";
  installPhase = "install -D NetAnim $out/bin/NetAnim";
  buildInputs = [ qtbase qmake qttools libGL ];
  nativeBuildInputs = [ wrapQtAppsHook ];
}

