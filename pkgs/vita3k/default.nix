{ stdenv
, lib
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, cmake
, ninja
, openssl
, pkg-config
, boost
, python3
, SDL2
, dbus
, zlib
}:

stdenv.mkDerivation rec {
  pname = "vita3k";
  version = "unstable-2022-10-12";

  src = fetchFromGitHub {
    owner = "Vita3K";
    repo = "Vita3K";
    rev = "8a151e587e40a2b7b143a635a887f9d5dd81e2cb";
    fetchSubmodules = true;
    sha256 = "";
  };

  postPatch = ''
    # Don't force the need for a static boost
    substituteInPlace CMakeLists.txt \
      --replace 'set(Boost_USE_STATIC_LIBS ON)' '# set(Boost_USE_STATIC_LIBS ON)'

    # Disable checks for .git directories
    substituteInPlace external/CMakeLists.txt \
      --replace 'check_submodules_present()' '# check_submodules_present()'

    # Use user-writable path for writing new files
    for fil in vita3k/{util/src/util,config/src/config,io/src/io}.cpp; do
      substituteInPlace $fil \
        --replace 'root_paths.get_base_path()' 'root_paths.get_pref_path()' \
        --replace 'base_path /' 'pref_path /'
    done
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    openssl
    boost
    python3
    SDL2
    dbus
    zlib
  ];

  # This thrashes ir/opt/* source code paths in external/dynarmic/src/dynarmic/CMakeLists.txt
  dontFixCmake = true;

  cmakeFlags = [
    "-DUSE_VITA3K_UPDATE=OFF"
    "-DUSE_DISCORD_RICH_PRESENCE=OFF" # tries to download something at configure time
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp -r bin $out/lib/${pname}
    ln -s $out/{lib/${pname},bin}/Vita3K
    install -Dm644 ../data/image/icon.png $out/share/icons/hicolor/128x128/apps/${pname}.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "Vita3K";
      exec = "Vita3K";
      icon = pname;
    })
  ];

  meta = with lib; {
    description = "Experimental PlayStation Vita emulator";
    homepage = "https://vita3k.org/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ annaaurora ];
  };
}
