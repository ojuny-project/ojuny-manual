# ojuny-manual

The long-form Ojuny manual. It is the place for installation, the desktop tour,
settings, updates, the command line, troubleshooting, and one walkthrough per
component. The tree holds 15 chapters plus the index and navigation.

One Markdown source tree feeds three outputs: GitHub renders the pages, mdBook
builds a static site, and the same build ships as an offline Nix package with
the Markdown tree, a launcher, a desktop entry, an icon, and an `fzf` + `bat`
TTY reader.

**Build and package status: verified on x86_64-linux, 2026-11-28.** `nix build`,
`nix flake check`, `--list`, and `--path` pass. The TTY reader is covered by the
package check with stub `fzf` and `bat` binaries; it has not been exercised in a
live terminal session.

## Read online

- GitHub: <https://github.com/ojuny-project/ojuny-manual/tree/main/src>
- Project site: <https://ojuny-project.github.io/ojuny-manual/> (not published
  yet)

## Install

```
nix profile install github:ojuny-project/ojuny-manual
```

This puts `ojuny-manual` on `PATH`. To run it without installing:

```
nix run github:ojuny-project/ojuny-manual
```

The package opens from a desktop entry and from a terminal. It needs no Ojuny
desktop, no `ojuny` command, no portal, no D-Bus, and no network.

## Read in a TTY

```
ojuny-manual
```

With no argument the launcher opens the chapter picker when stdout is a terminal
and no display is set. Otherwise it opens a browser.

```
ojuny-manual --gui     # browser
ojuny-manual --tty     # chapter picker even with a display
ojuny-manual --path    # print the installed Markdown directory
ojuny-manual --list    # chapter titles, one per line
ojuny-manual --serve   # serve on 127.0.0.1 and print the URL
```

The TTY reader uses `fzf` to pick a chapter and `bat` for the preview. Enter
opens the chapter through a `fzf` pager: type to filter, arrows or the mouse
scroll, `/` searches, and `Esc` or `Enter` exits.

## Build

```
nix build
./result/bin/ojuny-manual --list
```

For the book alone, with mdbook on `PATH`:

```
mdbook build
```

The output lands in `book/`, which is ignored by Git.

## Releases

A `v*` tag, a manual workflow run, or a commit on `main` whose title starts with
a version such as `v0.1.0` builds `ojuny-manual-x86_64` and
`ojuny-manual-flake.tar.gz`.

The release flake installs the prebuilt book and launcher without compiling:

```nix
inputs.ojuny-manual.url =
  "tarball+https://github.com/ojuny-project/ojuny-manual/releases/download/vX.Y.Z/ojuny-manual-flake.tar.gz";
```

Add `inputs.ojuny-manual.packages.${pkgs.system}.ojuny-manual` to
`environment.systemPackages`.


## License

GPL-3.0. See [LICENSE](LICENSE).
