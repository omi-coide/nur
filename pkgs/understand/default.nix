{ config, pkgs, lib, ... }:
let
  src = pkgs.requireFile {
    name = "Understand-5.1.1029-Linux-64bit.tgz";
    message = ''
      This nix expression requires that Understand5.1 is
      already part of the store. Find the file on your Mathematica CD
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "sha256-t0PF1JrKoIxGhxIg6ByAQ8Ls46YKR5L0Mnr0c98K31I=";
  };
  makeWrapper = pkgs.makeWrapper;
  mkDerivation = pkgs.stdenv.mkDerivation;
  autoPatchelfHook = pkgs.autoPatchelfHook;
in
mkDerivation {
  name = "scitoolsUnderstand";

  meta = with lib; {
    description = "A powerful source code analysis tool for better visibility and control.";
    homepage = "https://scitools.com/understand/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = ["omi-coide"];
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
    expat
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
    pciutils
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
    rm $out/bin/linux64/libfreetype.so.6
    chmod a-x $out/bin/linux64/lib*.so*
    find $out/bin/linux64 -name '*.so*' |xargs chmod a-x
    autoPatchelf $out
    patchelf --add-rpath $out/bin/linux64/Plugins/platforms $out/bin/linux64/understand
    wrapProgram "$out/bin/linux64/understand" --set JAVA_HOME "${pkgs.jre_minimal.home}"
    ln -s $out/bin/linux64/understand $out/bin/understand
  '';
  dontFixup = true;
  autoPatchelfIgnoreMissingDeps = true;

}
