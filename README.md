# ojuny-manual

The long-form Ojuny manual. It is the place for installation, the desktop tour,
settings, updates, the command line, troubleshooting, and one walkthrough per
component. The tree holds 15 chapters plus the index and navigation.

One Markdown source tree feeds three outputs: GitHub renders the pages, mdBook
builds a static site, and the same build ships as an offline Nix package with a
launcher, a desktop entry, an icon, and a bundled `w3m`.

**Build and package status: unverified.** The flake, the launcher, and the
package have not been built or run.

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

With no argument the launcher opens the index in the bundled `w3m` when stdout
is a terminal and no display is set. Otherwise it opens a browser.

```
ojuny-manual --gui     # browser
ojuny-manual --path    # print the installed index path
ojuny-manual --list    # chapter titles, one per line
ojuny-manual --serve   # serve on 127.0.0.1 and print the URL
```

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

## License

GPL-3.0. See [LICENSE](LICENSE).
