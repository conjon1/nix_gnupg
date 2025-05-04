# default.nix
{ pkgs ? import <nixpkgs> {} }: # Import the nixpkgs collection

let
  # --- Define Sources ---
  # Source for the specific libgcrypt version
  libgcrypt_1_11_0_src = pkgs.fetchurl {
    url = "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.0.tar.bz2";
    # Use the CORRECT SHA256 hash for libgcrypt-1.11.0
    sha256 = "09120c9867ce7f2081d6aaa1775386b98c2f2f246135761aae47d81f58685b9c";
  };

  # Source for the specific GnuPG version
  gnupg_2_5_5_src = pkgs.fetchurl {
    url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.5.5.tar.bz2";
    sha256 = "7afa71d72ff9aaff75a6810b87b486bc492fd752e4f77b07c41759ce4ef36b31";
  };

  # --- Define Custom Dependencies (if needed) ---
  
  libgcrypt_1_11_0_built = pkgs.stdenv.mkDerivation {
    pname = "libgcrypt";
    version = "1.11.0";
    src = libgcrypt_1_11_0_src;

    # libgcrypt depends on libgpg-error. Use the one from pkgs.
    buildInputs = [ pkgs.libgpg-error ];
    nativeBuildInputs = [ pkgs.pkg-config ]; 
    #always nice to above
    configureFlags = [ ];

    meta = with pkgs.lib; {
      description = "GNU cryptographic library (custom build)";
      homepage = "https://gnupg.org/software/libgcrypt/";
      license = licenses.lgpl21Plus;
      platforms = platforms.unix;
    };
  };

in

pkgs.stdenv.mkDerivation {
  pname = "gnupg";
  version = "2.5.5"; # Updated version

  src = gnupg_2_5_5_src; # Use the source defined above

  buildInputs = with pkgs; [
    zlib
    bzip2
    readline
    ncurses
    libgcrypt_1_11_0_built # <--- Reference custom built libgcrypt here
    libgpg-error           # GnuPG still needs this directly
    libassuan
    libksba
  ];

  # Tools needed specifically during the build process
  nativeBuildInputs = with pkgs; [
    npth
    perl
    pkg-config
  ];

  configureFlags = [];

  meta = with pkgs.lib; {
    description = "GNU Privacy Guard (built from custom source, with custom libgcrypt)";
    homepage = "https://gnupg.org/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
