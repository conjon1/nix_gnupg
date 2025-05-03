# /gnupg_custom/default.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "gnupg";
  version = "2.4.7"; #  figured id do the latest 

  #exract tarball URL & Sha
  src = pkgs.fetchurl {
    url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.7.tar.bz2";
    sha256 = "7b24706e4da7e0e3b06ca068231027401f238102c41c909631349dcc3b85eb46";
  };

  # from nixpkgs
  buildInputs = with pkgs; [
    zlib
    bzip2
    readline
    ncurses
    libgcrypt
    libgpg-error
    libassuan
    libksba
    #npth <-- does not go here
];
 nativeBuildInputs = with pkgs; [
    npth # <-- but goes here?
    perl 
    pkg-config 

  ];

  # might need later
  configureFlags = [];


  meta = with pkgs.lib; {
    description = "GNU Privacy Guard (built from custom source)";
    homepage = "https://gnupg.org/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
