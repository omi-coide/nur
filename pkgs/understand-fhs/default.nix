{ config, pkgs, lib, ... }:
let
  understand-dist = pkgs.mkDerivation
    {
      name = "scitools-Understand-noFHS";
      meta = with lib; {
        description = "A powerful source code analysis tool for better visibility and control.(not Wrapped)";
        homepage = "https://scitools.com/understand/";
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        license = licenses.unfree;
        platforms = [ "x86_64-linux" ];
        maintainers = "omi-coide";
        broken = true;
      };
      src = pkgs.fetchurl {
        url = "https://latest.scitools.com/Understand/Understand-6.3.1136-Linux-64bit.tgz";
        sha256 = "sha256-ftF1bAaFvZtbPThQeEONrUSj/nKx2iySfDT7SxRx+5M=";
      };
      unpackPhase = ''
        runHook preUnpack
        tar -C $TMPDIR -xvf $src scitools/
        runHook postUnpack
      '';

      buildPhase = ''
        mv $TMPDIR/scitools $out
      '';
      dontFixup = true;

    }

    in    (pkgs.buildFHSUserEnv {
    name = "understand-fhs";
  targetPkgs = with pkgs;[
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
  runScript = "${understand-dist}/bin/linux64/understand";
  }).env
#     mkDerivation {
#     name = "";
#   installPhase = ''
#     mkdir -p $out/bin $out/share/applications
#         ln -s ${startScript} $out/bin/understand
#     ln -s ${desktopFile} $out/share/applications/Understand.desktop
#     ln -s ${svp-dist}/share/icons $out/share/icons
#   '';

#   }


#   mpvForSVP = wrapMpv
#     (mpv-unwrapped.override {
#       vapoursynthSupport = true;
#     })
#     {
#       extraMakeWrapperArgs = lib.optionals (nvidia_x11 != null) [
#         "--prefix"
#         "LD_LIBRARY_PATH"
#         ":"
#         "${lib.makeLibraryPath [ nvidia_x11 ]}"
#       ];
#     };

#   # SVP 主程序的依赖
#   libPath = lib.makeLibraryPath [
#     libsForQt5.qtbase
#     libsForQt5.qtdeclarative
#     libsForQt5.qtscript
#     libsForQt5.qtsvg
#     libmediainfo
#     libusb1
#     xorg.libX11
#     stdenv.cc.cc.lib
#     ocl-icd
#     vapoursynth
#   ];

#   # SVP 查找二进制程序的路径（即 PATH 环境变量）
#   execPath = lib.makeBinPath [
#     ffmpeg.bin
#     gnome.zenity
#     lsof
#     xdg-utils
#   ];

#   svp-dist = stdenv.mkDerivation rec {
#     pname = "svp-dist";
#     version = "4.5.210";
#     src = fetchurl {
#       url = "https://www.svp-team.com/files/svp4-linux.${version}-1.tar.bz2";
#       sha256 = "10q8r401wg81vanwxd7v07qrh3w70gdhgv5vmvymai0flndm63cl";
#     };

#     nativeBuildInputs = [ p7zip patchelf ];

#     # 禁用修补步骤（Fixup phase），它会修改 SVP 二进制文件，导致完整性校验报错
#     dontFixup = true;

#     # 解压、安装步骤来自 AUR：https://aur.archlinux.org/packages/svp-bin
#     unpackPhase = ''
#       tar xf ${src}
#     '';

#     buildPhase = ''
#       mkdir installer
#       LANG=C grep --only-matching --byte-offset --binary --text  $'7z\xBC\xAF\x27\x1C' "svp4-linux-64.run" |
#         cut -f1 -d: |
#         while read ofs; do dd if="svp4-linux-64.run" bs=1M iflag=skip_bytes status=none skip=$ofs of="installer/bin-$ofs.7z"; done
#     '';

#     installPhase = ''
#       mkdir -p $out/opt
#       for f in "installer/"*.7z; do
#         7z -bd -bb0 -y x -o"$out/opt/" "$f" || true
#       done

#       for SIZE in 32 48 64 128; do
#         mkdir -p "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps"
#         mv "$out/opt/svp-manager4-''${SIZE}.png" "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps/svp-manager4.png"
#       done
#       rm -f $out/opt/{add,remove}-menuitem.sh
#     '';
#   };

#   # 创建一个使用 Bubblewrap 的启动脚本
#   startScript = writeShellScript "SVPManager" ''
#     # 除了这些路径以外，其它的根目录下的路径都映射进虚拟环境
#     # 这里的有些路径不是完全不映射，而是在下面有更细粒度的映射配置
#     blacklist=(/nix /dev /usr /lib /lib64 /proc)

#     declare -a auto_mounts
#     # loop through all directories in the root
#     for dir in /*; do
#       # if it is a directory and it is not in the blacklist
#       if [[ -d "$dir" ]] && [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
#         # add it to the mount list
#         auto_mounts+=(--bind "$dir" "$dir")
#       fi
#     done

#     # Bubblewrap 启动脚本
#     cmd=(
#       ${bubblewrap}/bin/bwrap
#       # /dev 需要特殊的映射方式
#       --dev-bind /dev /dev
#       # 在虚拟环境中也切换到当前文件夹
#       --chdir "$(pwd)"
#       # Bubblewrap 退出时杀掉虚拟环境里的所有进程
#       --die-with-parent
#       # /nix 目录只读
#       --ro-bind /nix /nix
#       # /proc 需要特殊的映射方式
#       --proc /proc
#       # 把 Glibc 放到 /lib 和 /lib64，让 SVP 加载
#       --bind ${glibc}/lib /lib
#       --bind ${glibc}/lib /lib64
#       # 一些 SVP 需要用到的命令，SVP 固定去 /usr/bin 查找这些命令
#       --bind /usr/bin/env /usr/bin/env
#       --bind ${ffmpeg.bin}/bin/ffmpeg /usr/bin/ffmpeg
#       --bind ${lsof}/bin/lsof /usr/bin/lsof
#       # 配置环境变量，包括查找命令和库的路径
#       --setenv PATH "${execPath}:''${PATH}"
#       --setenv LD_LIBRARY_PATH "${libPath}:''${LD_LIBRARY_PATH}"
#       # 把 SVP 专用的 MPV 播放器映射过来
#       --symlink ${mpvForSVP}/bin/mpv /usr/bin/mpv
#       # 映射其它根目录下的路径
#       "''${auto_mounts[@]}"
#       # 虚拟环境启动后运行 SVP 主程序
#       ${svp-dist}/opt/SVPManager "$@"
#     )
#     exec "''${cmd[@]}"
#   '';

#   # SVP 菜单项
#   desktopFile = writeText "Understand.desktop" ''
#     [Desktop Entry]
#     Version=${version}
#     Encoding=UTF-8
#     Name=SVP 4 Linux
#     GenericName=Real time frame interpolation
#     Type=Application
#     Categories=Multimedia;AudioVideo;Player;Video;
#     MimeType=video/x-msvideo;video/x-matroska;video/webm;video/mpeg;video/mp4;
#     Terminal=false
#     StartupNotify=true
#     Exec=${startScript} %f
#     Icon=svp-manager4.png
#   '';
# in
# # 创建一个简单的包，只包含启动脚本和菜单项
# stdenv.mkDerivation {
#   pname = "svp";
#   inherit (svp-dist) version;
#   phases = [ "installPhase" ];
#   installPhase = ''
#     mkdir -p $out/bin $out/share/applications
#     ln -s ${startScript} $out/bin/SVPManager
#     ln -s ${desktopFile} $out/share/applications/svp-manager4.desktop
#     ln -s ${svp-dist}/share/icons $out/share/icons
#   '';
# }
