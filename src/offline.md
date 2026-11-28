# Reading offline

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested in a live session. Applies to 2026-11-28. The package builds,
> its checks pass, and the TTY reader is covered with stub `fzf` and `bat`
> binaries.

The manual installs as a Nix package that contains the built HTML book, the
Markdown tree, a launcher, a desktop entry, an icon, and an `fzf` + `bat` TTY
reader. It needs no Ojuny desktop, no `ojuny` command, no D-Bus session, and no
network.

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

`--path` prints the installed Markdown directory and `--list` prints the chapter
titles. Neither command opens a reader.

## In a terminal

```sh
ojuny-manual
```

With no argument the launcher checks the session. If stdout is a terminal and
neither `DISPLAY` nor `WAYLAND_DISPLAY` is set, it opens the `fzf` chapter
picker. Otherwise it behaves like `--gui`.

Use `--tty` to force the chapter picker from a graphical session:

```sh
ojuny-manual --tty
```

The picker lists every chapter and shows a `bat` preview on the right. Type to
filter, use the arrow keys to move, and press `Enter` to open a chapter. `Esc`
quits.

The chapter opens through a `fzf` pager. Scroll with the arrow keys, the mouse,
or `Page Up` and `Page Down`; `/` searches the page; `Esc` or `Enter` exits.

The reader shows the Markdown text only. Theme and keybind sections in the book
describe the Ojuny desktop session, not the reader.

## From the desktop

```sh
ojuny-manual --gui
```

The desktop menu entry runs the same command. It opens the HTML index through
`xdg-open`, then `$BROWSER`, and prints the index path if neither works.

## When nothing opens

```sh
ojuny-manual --path    # the installed Markdown directory
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

The package and the launcher pass their checks, but the TTY reader has not been
run in a live terminal. The offline book covers this manual only. Repository
links and the site need network access. The HTML book does not run JavaScript,
so interactive elements do not work. Theme selection and keybinds in the book
describe the desktop session. The TTY reader uses `fzf` and `bat` colors and
keys; the manual does not set either. `--serve` binds only to `127.0.0.1` and
runs in the foreground.
