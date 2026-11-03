# Reading offline

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `83536b7`, 2026-11-03. The package builds
> and its checks pass; the TTY reader and desktop entry have not been run in a
> session.

The manual installs as a Nix package that contains the built book, a launcher,
a desktop entry, an icon, and a bundled `w3m`. It needs no Ojuny desktop, no
`ojuny` command, no D-Bus session, and no network.

## Install

```sh
nix profile install github:ojuny-project/ojuny-manual
```

This puts `ojuny-manual` on `PATH`. To try it without installing:

```sh
nix run github:ojuny-project/ojuny-manual
```

Verify the launcher before opening a reader:

```sh
ojuny-manual --path
ojuny-manual --list
```

`--path` prints the installed index page and `--list` prints the chapter titles.
Neither command opens a reader.

## In a terminal

```sh
ojuny-manual
```

With no argument the launcher checks the session. If stdout is a terminal and
neither `DISPLAY` nor `WAYLAND_DISPLAY` is set, it opens the index in the
bundled `w3m`. Otherwise it behaves like `--gui`.

`w3m` navigation: arrow keys scroll, `Tab` moves to the next link, `Enter`
follows it, `q` quits.

## From the desktop

```sh
ojuny-manual --gui
```

The desktop menu entry runs the same command. It opens the index through
`xdg-open`, then `$BROWSER`, and prints the index path if neither works.

## When nothing opens

```sh
ojuny-manual --path    # the installed index.html
ojuny-manual --list    # chapter titles, one per line
ojuny-manual --serve   # http://127.0.0.1:<port>/ in the foreground
```

`--serve` picks a free port on `127.0.0.1` and prints the URL. It runs in the
foreground, so `Ctrl-C` stops it and nothing survives the shell.

## Build from source

```sh
git clone https://github.com/ojuny-project/ojuny-manual
cd ojuny-manual
nix build
./result/bin/ojuny-manual --path
```

The book alone is built with `mdbook build` and lands in `book/`.

## Limits

The package and the launcher have not been built or run, so every command above
is untested. The offline book covers this manual only. Repository links and the
site need network access. The bundled `w3m` renders text and tables but not
JavaScript, so interactive elements do not work. `--serve` binds only to
`127.0.0.1` and runs in the foreground.
