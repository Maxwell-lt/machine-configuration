{ stdenv
, pkgs
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  name = "powerpanel-v${version}";
  version = "1.3.3";

  src = fetchurl {
    url = "https://dl4jz3rbrsfum.cloudfront.net/software/PPL-1.3.3-64bit.tar.gz";
    sha256 = "0isr1a5lp46x56p8ijhlz309zp2k52i95aajq5xvk57j2lxhxanx";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    tar -xf $src
    cd powerpanel-${version}

    mkdir -p $out/bin
    cp bin/pwrstat $out/bin
    cp bin/pwrstatd $out/bin

    mkdir -p $out/share/man/man8
    gzip -c doc/pwrstat.8 > $out/share/man/man8/pwrstat.8.gz
    gzip -c doc/pwrstatd.8 > $out/share/man/man8/pwrstatd.8.gz
  '';

  meta = with stdenv.lib; {
    license = licenses.unfree;
    homepage = "https://www.cyberpowersystems.com/product/software/powerpanel-for-linux/";
    description = "Monitoring tool for CyberPower UPS units";
    platforms = platforms.linux;
    maintainers = with maintainers; [ maxwell-lt ];
  };
}
