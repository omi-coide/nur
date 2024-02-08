{ config, pkgs, lib, ... }:
let
  understand-dist = pkgs.stdenv.mkDerivation
    {
      name = "scitools-Understand-noFHS";
      meta = with lib; {
        description = "A powerful source code analysis tool for better visibility and control.(not Wrapped)";
        homepage = "https://scitools.com/understand/";
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        license = licenses.unfree;
        platforms = [ "x86_64-linux" ];
        maintainers = [ "omi-coide" ];
      };
      src = pkgs.requireFile {
        name = "Understand-5.1.1029-Linux-64bit.tgz";
        message = ''
          This nix expression requires that Understand5.1 is
          already part of the store. Find the file on your Mathematica CD
          and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
        '';
        sha256 = "sha256-t0PF1JrKoIxGhxIg6ByAQ8Ls46YKR5L0Mnr0c98K31I=";
      };
      unpackPhase = ''
        runHook preUnpack
        tar -C $TMPDIR -xvf $src scitools/
        mv $TMPDIR/scitools $out
        runHook postUnpack
      '';

      buildPhase = ''
        rm $out/bin/linux64/libfreetype.so.6
      '';
      dontFixup = true;

    };

in
(pkgs.buildFHSUserEnv {
  name = "understand-fhs";
  targetPkgs = pkgs: (with pkgs;[
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
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXi
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
  ]);
  runScript = "${understand-dist}/bin/linux64/understand";
})
