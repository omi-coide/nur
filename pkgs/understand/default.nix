{ config, pkgs, lib, ... }:
let
  src = pkgs.fetchurl {
    url = "https://latest.scitools.com/Understand/Understand-6.3.1136-Linux-64bit.tgz";
    sha256 = "sha256-ftF1bAaFvZtbPThQeEONrUSj/nKx2iySfDT7SxRx+5M=";
  };
  makeWrapper = pkgs.makeWrapper;
  mkDerivation = pkgs.stdenv.mkDerivation;
  autoPatchelfHook = pkgs.autoPatchelfHook;
  buildFHSUserEnv = pkgs.buildFHSUserEnv;
in
mkDerivation {
  name = "scitoolsUnderstand";

  meta = with lib; {
    description = "A powerful source code analysis tool for better visibility and control.";
    homepage = "https://scitools.com/understand/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = "omi-coide";
    broken = true;
  };
  inherit src;
  nativeBuildInputs = [
    makeWrapper
  ];
  buildInputs = with pkgs;[
    autoPatchelfHook
    alsaLib
    astyle
    cups
    dbus
    fontconfig
    freetype
    glib
    glibc
    gtk2
    jre_minimal
    krb5
    libGL
    libxcrypt
    libxkbcommon
    lzma
    mesa
    ncurses
    nspr
    nss
    python310
    util-linux
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdmcp
    xorg.libXext
    xorg.libXfixes
    xorg.libxkbfile
    xorg.libXrandr
    xorg.libXrender
    xorg.libxshmfence
    xorg.libXtst
    xorg.xcbutilwm # libxcb-icccm.so.4
    xorg.xcbutilimage # libxcb-image.so.0
    xorg.xcbutilkeysyms # libxcb-keysyms.so.1
    xorg.xcbutilrenderutil # libxcb-render-util.so.0
    zlib
    zstd
  ];
  unpackPhase = ''
    runHook preUnpack
    tar -C $TMPDIR -xvf $src scitools/
    mv $TMPDIR/scitools $out
    runHook postUnpack
  '';

  installPhase = ''
    autoPatchelf $out
    patchelf --add-rpath $out/bin/linux64/Plugins/platforms $out/bin/linux64/understand
    wrapProgram "$out/bin/linux64/understand" --set JAVA_HOME "${pkgs.jre_minimal.home}"
    ln -s $out/bin/linux64/understand $out/bin/understand
  '';
  dontFixup = true;
  autoPatchelfIgnoreMissingDeps = true;

}
