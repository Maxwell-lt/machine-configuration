{ stdenv
, pkgs
, fetchurl
, patchelf
, autoPatchelfHook
, lib }:

stdenv.mkDerivation rec {
  name = "svp-v${version}";
  version = "4.3.191";

  src = fetchurl {
    url = "https://www.svp-team.com/files/svp4-linux.${version}-1.tar.bz2";
    sha256 = "0s543xgs4n8c6myy3krznbkkn513dl0vj9miyda8jpp3gwkp16dj";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    glibc
    xlibs.libX11
    qt5.qtbase
    qt5.qtdeclarative
    gcc-unwrapped.lib
    vapoursynth
    avahi
    libusb1
    ocl-icd
    makeWrapper
  ];

  unpackPhase = with pkgs; ''
    ${gnutar}/bin/tar xf $src
    mkdir installer
    ${gnugrep}/bin/grep --only-matching --byte-offset --binary --text  $'7z\xBC\xAF\x27\x1C' "svp4-linux-64.run" |
        ${coreutils}/bin/cut -f1 -d: |
        while read ofs; do ${coreutils}/bin/dd if=svp4-linux-64.run bs=1M iflag=skip_bytes status=none skip=$ofs of="installer/bin-$ofs.7z"; done
    for f in installer/*.7z; do
        ${p7zip}/bin/7z -bd -bb0 -y x -o"extracted/" "$f" || true
    done;
  '';

  installPhase = with pkgs; ''
    mkdir -p $out/opt/svp
    mkdir -p $out/bin
    mkdir -p $out/usr/share/licenses/svp

    if [[ -d extracted/licenses ]]; then
      mv extracted/licenses $out/usr/share/licenses/svp
    fi
    mv extracted/* $out/opt/svp
    ln -s $out/opt/svp/extensions/libQtWebApp.so $out/opt/svp/extensions/libQtWebApp.so.1
    ln -s $out/opt/svp/extensions/libQtZeroConf.so $out/opt/svp/extensions/libQtZeroConf.so.1
    ln -s $out/opt/svp/extensions/libPythonQt.so $out/opt/svp/extensions/libPythonQt.so.1

    chmod -R +rX $out/opt/svp $out/usr/share

    makeWrapper $out/opt/svp/SVPManager $out/bin/SVPManager \
      --prefix PATH : ${lib.makeBinPath [ gnome3.zenity lsof mediainfo clinfo vapoursynth (mpv.override { vapoursynthSupport = true; })]} \
  '';
}
