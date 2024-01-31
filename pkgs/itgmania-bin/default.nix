{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, alsa-lib
, freetype
, gtk3
, libjack2
, libglvnd
, libGLU
, libpulseaudio
, libusb-compat-0_1
, xorg
, makeDesktopItem
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "itgmania-bin";
  version = "0.7.0";

  src = {
    x86_64-linux = fetchurl {
      url = "https://github.com/itgmania/itgmania/releases/download/v0.7.0/ITGmania-0.7.0-Linux.tar.gz";
      hash = "sha256-Bw0Iq+ILUQMq9WMCN5FsJXN6+nF7JKxNtKmfZHd6CfU=";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    freetype
    gtk3
    libjack2
    libglvnd
    libGLU
    libpulseaudio
    libusb-compat-0_1
    xorg.libXtst
  ];

  desktop = makeDesktopItem {
    name = "itgmania";
    desktopName = "ITGmania";
    genericName = "Rhythm and dance game";
    exec = "itgmania";
    tryExec = "itgmania";
    icon = "itgmania";
    categories = [ "Game" "ArcadeGame" ];
  };

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/48x48/apps
    cp -r itgmania $out/share
    cp itgmania/Data/icon.png $out/share/icons/hicolor/48x48/apps/itgmania.png
    ln -s ${desktop}/share/applications/itgmania.desktop $out/share/applications/itgmania.desktop
    makeWrapper $out/share/itgmania/itgmania $out/bin/itgmania --argv0
  '';

  meta = with lib; {
    description = "A rhythm game engine forked from StepMania 5.1 with enhanced networking support";
    homepage = "https://www.itgmania.com";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ maxwell-lt ];
    mainProgram = "itgmania";
  };
}
