{ stdenv, lib, fetchurl, makeWrapper, yacc, gcc
, withISpin ? true, tk, swarm, graphviz }:

let
  binPath = stdenv.lib.makeBinPath [ gcc ];
  ibinPath = stdenv.lib.makeBinPath [ gcc tk swarm graphviz tk ];

in stdenv.mkDerivation rec {
  name = "spin-${version}";
  version = "6.4.6";
  url-version = stdenv.lib.replaceChars ["."] [""] version;

  src = fetchurl {
    # The homepage is behind CloudFlare anti-DDoS protection, which blocks cURL.
    # Dropbox mirror from developers:
    # https://www.dropbox.com/sh/fgzipzp4wpo3qc1/AADZPqS4aoR-pjNF6OQXRLQHa
    url = "https://www.dropbox.com/sh/fgzipzp4wpo3qc1/AAA-vBeJ7xty-CDZgk7OB58Ta/spin646.tar.gz?raw=1";
    sha256 = "1n33qzlb7g30vhr5yxssw210b2m0242y9j21c7fqpn9z6b0rbhjp";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ yacc ];

  sourceRoot = "Spin/Src${version}";

  installPhase = ''
    install -Dm755 spin $out/bin/spin
    wrapProgram $out/bin/spin \
      --prefix PATH : ${binPath}
  '' + lib.optionalString withISpin ''
    install -Dm755 ../iSpin/ispin.tcl $out/bin/ispin
    wrapProgram $out/bin/ispin \
      --prefix PATH ':' "$out/bin:${ibinPath}"
  '';

  meta = with stdenv.lib; {
    description = "Formal verification tool for distributed software systems";
    homepage = http://spinroot.com/;
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mornfall pSub ];
  };
}
