# nix_gnupg
this is a nix file for gnupg for unix systems, my personal systm is arch


# nix & gnupg
I was going to build from source, but i could see a problem happening with the path i needed to take with the path that i would need to put the because of the /usr/ directory and it caused pacman to scream at me when downgraded the core packages and re-upgraded due package conflicts
even when moving the package to /usr/local it shits bricks when i downgrade and regrade due to core package conflicts

After a bit of research the arch core packages of gnupg is in fact different the source (why i dont really know just that the maintainer just has diverged) and also don't want to keep updating the source whenever a new version comes out.

So i figured i would use nix, it has its own separate file system i can flake into and use the program from there as opposed to in the /usr/ paths i can nust put it into the /nix/ path and flake into it when i need it

## The process
first I need to install nix
follow the guide for your system but here is mine:
```
sudo pacman -S nix
```
or directly from the website (this is for multi user)
```
sh <(curl -L https://nixos.org/nix/install) --daemon  
```

Then i need to get the daemon working (if you used the install script that nixos provided then you a can skip this)
```
sudo systemctl enable nix-daemon          
sudo systemctl start nix-daemon
```

Then in my project folder
```
mkdir nix_files/gnupg_custom
```

now that nix is up and running we need to create a nix file

that is the default.nix file - feel free to edit the code as you like it is only 43 lines

 a couple cool things about this section:
 ```
# lines 8 - 12
src = pkgs.fetchurl {
    url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.7.tar.bz2";
    sha256 = "7b24706e4da7e0e3b06ca068231027401f238102c41c909631349dcc3b85eb46";
  };
``` 
Nix actually calculates the SHA256 value
Here's how it works:
1. When Nix evaluates this derivation, it sees that it needs the source from that URL.
2. It attempts to download the file from `"https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.7.tar.bz2"`.
3. **Crucially, after downloading the file, Nix calculates its SHA256 hash.**
4. Nix then **compares the calculated hash** of the downloaded file to the `sha256` 
5. **If the hashes do _not_ match, Nix will abort the build** with a "hash mismatch" error.


### Building the package
to build the package using this expression, run:
```
nix-build default.nix
```
### Using out new nix build

This will download the source and dependencies (if not cached), build GnuPG in an isolated environment, and create a result symlink pointing to the built package in the Nix store.

After nix-build completes successfully, it creates a symlink named result in the directory where you ran the command. This result symlink points to the location of your built GnuPG package within the Nix store.

You have a few ways to use this specific build, all of which keep it isolated from my main Arch system:

##### 1. Directly using the result symlink (Quick Test):
For a quick check, you can run the gpg executable directly:
```
./result/bin/gpg --version
```

##### 2. Using nix-shell (Recommended for Isolated Work):
This is the best way to get a temporary shell environment where your custom GnuPG build is available in the PATH, along with any other tools you need (like vim and pinentry for key generation).

Create a file named shell.nix in the same directory

```
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

let
  my-gnupg = pkgs.callPackage ./default.nix {};
in

pkgs.mkShell {
# adds tools
  packages = [
    my-gnupg      
    pkgs.vim      
    pkgs.pinentry 
  ];

  # Optional: Add a message when entering the shell
  shellHook = ''
     echo "Entering shell with custom GnuPG ${my-gnupg.version}, vim, and pinentry."
     echo "Run 'gpg --version' to confirm the build."
     echo "Run 'gpg --full-generate-key' to create a new key."
  '';
}
```
then simply run:
```
nix-shell
```


**Isolation Achieved:**

Regardless of whether you use the `result` symlink, `nix-shell`, or `nix-env`, the GnuPG executable and all its dependencies live exclusively in the `/nix/store/` directory tree. The system's `/usr/bin/gpg` and its libraries, managed by pacman, are completely untouched. This ensures that your custom build does not conflict with system packages.


**Cleaning Up:**

If you decide you no longer need this specific build (e.g., you build a newer version or switch back to the Arch package), you can remove the `result` symlink and uninstall from your user profile if you used `nix-env`. The actual files in the Nix store will remain until you run Nix's garbage collector to remove unused packages:
```
nix-collect-garbage -d 
```


---
# References
[gnupg.org](gnupg.org)
	[sumcheck](https://gnupg.org/download/integrity_check.html)
	[mirrors](https://gnupg.org/download/mirrors.html)
	[git](https://gnupg.org/download/git.html)
[Arch Wiki](https://wiki.archlinux.org)
	[GnuPG](https://wiki.archlinux.org/title/GnuPG)
	[Nix on arch](https://wiki.archlinux.org/title/Nix)
[Nix](nixos.org)
	[Download](https://nixos.org/download/#download-nix)
	[How nix uses SHA256](https://ryantm.github.io/nixpkgs/builders/fetchers/)
[WebOfTrust](https://en.wikipedia.org/wiki/Web_of_trust)
https://datatracker.ietf.org/doc/draft-koch-librepgp/



