# Linux Notes


## pacman

- [luke smith's video](https://www.youtube.com/watch?v=-dEuXTMzRKs)

```bash
pacman -S -> for install related things, search in repos, etc.
pacman -R -> to remove
pacman -Q -> to query installed ones
```

To query which package (from the repos, provides a file)

```bash
pacman -Fy filename
pacman -Fy libsane.so
pacman -F dig
```

(`y` is for syncing, so once you have done that, you may skip that if you are running the command instantly later).

```bash
pacman -Syu -> sync and update the system
pacman -S bind -> install package `bind` but do this only after once you have synced and updated recently
pacman -Ss zathura -> search for `zathura` package, this will show all the packages having zathura in their name or description
pacman -Rs telegram-desktop -> remove `telegram-desktop` package along with its dependencies.
pacman -R zathura-pdf-poppler -> remove this package, leaving behind any dependencies that it might have.
pacman -Rns telegram-desktop -> remove this package, along with the conf files and dependencies.
pacman -Q -> lists all the packages installed on the system
pacman -Qe -> lists all the packages installed by you (or installed as a dep of a program that you installed)
pacman -Qdt -> lists the packages that are kinda orphaned, they were installed as a dep by another program but the another program no longer exists and so they are not needed by any other program and so they can be removed.
pacman -Q | wc -l -> wew, counts the number of packages, lol
```

Configure the following options in `/etc/pacman.conf` -

`Color` -> for having colored output in pacman results  

`ILoveCandy` -> for having pacman icon instead of hash-sign on progress-bar in pacman results.


## which package provides a missing file?

```plaintext
vncviewer: error while loading shared libraries: libcrypt.so.1: cannot open shared object file: No such file or directory
```

This most probably means that some package which provides this missing lib file is currently not installed.

```bash
$ pkgfile -s libcrypt.so                                                 
core/libxcrypt
community/aarch64-linux-gnu-glibc
community/riscv64-linux-gnu-glibc
multilib/lib32-libxcrypt
```

Now, we can install any of these packages (example: `sudo pacman -S libxcrypt`)


## tweaks and utilities

- `pandoc` for converting `.md` to `.pdf`, etc.

```bash
sudo pacman -Syu pandoc texlive-core texlive-fontsextra texlive-latexextra

pandoc file.md -o file.pdf
```

## change default shell

List all the available shells -  

```bash
$ chsh -l

/bin/sh
/bin/bash
/bin/zsh
/usr/bin/zsh
/usr/bin/git-shell
/usr/bin/fish
/bin/fish
```

Example to change to `fish` shell -   

```bash
$ chsh -s /bin/fish

changing shell for devpogi.
Password: 
Shell changed.
```

You might need to logout and login again for the changes to take place.


## networks


- [Ben Eater's video explaining BGP and DNS](https://www.youtube.com/watch?v=-wMU8vmfaYo)

```bash
dig @root-server-ip www.facebook.com
```

[root servers ip](https://www.iana.org/domains/root/servers)


## cheatsheets

```bash
curl cheat.sh/<query>
curl cheat.sh/pacman
curl cheat.sh/git-status
```

