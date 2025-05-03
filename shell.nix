# shell.nix
{ pkgs ? import <nixpkgs> {} }:

let
  
  my-gnupg = pkgs.callPackage ./default.nix {};
in
# packages to be included in the shell
pkgs.mkShell {
  packages = [ 
    my-gnupg
    pkgs.vim
    pkgs.nano
    pkgs.pinentry
  ];

# Optional: makes it fancy
shellHook = ''
     echo "Entering shell with custom GnuPG ${my-gnupg.version}, vim, and pinentry."
     echo "Run 'gpg --version' to confirm the build."
     echo "Run 'gpg --full-generate-key' to create a new key."
  '';
}




