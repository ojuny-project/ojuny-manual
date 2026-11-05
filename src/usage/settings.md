# Settings menu

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `904c038`, 2026-11-03. The window, save
> path, and scanner rules are described from the code; no run is recorded.

## What this covers

How to open the settings menu, read its panes, change a value, save, and rebuild,
and why a control can be missing. It does not list the options. The option
reference lives in the desktop repository, and each page file is the authority
for its own annotations.

## What the menu is

`nix-settings-gui` reads `@menu` and `@option` comments from the Nix source and
renders one control per annotation. One file with a `@menu` header becomes one
menu. A file without that header is skipped, which is how generated hardware and
under-the-hood modules stay out of the window.

The GUI edits the source text. It does not keep a second configuration store.
A change is written back into the same module, checked with `rnix`, formatted
with `nixfmt`, and written atomically.

## Open it

Start the settings menu from the application menu. The template also installs
`nix-regedit`, `nix-shell-gui`, and `simple-nix-update-gui`.

`ojuny settings open <page>` is different: it opens a Dux Modular Shell settings page
for the running session, not the Nix settings window.

On first start, choose the flake or configuration directory with the selector at
the top. Recent paths appear in the selector.

## Read the window

The left pane lists every menu the scanner found, grouped by the `@menu`
category string and sorted by its `order` value. Category prefixes such as
`02-Core` are printed as part of the heading.

The right pane shows the selected menu: its header, grouped controls, and an
Advanced section. Controls marked `advanced` are folded into that section. A
control marked `hidden` appears only while the Advanced toggle is on.

Each control shows its label, helper text, and a marker when the staged value
differs from the file. The search box filters both the menu list and the visible
controls. The system only checkbox narrows the list to pages the selected host
imports.

Option types, descriptions, defaults, and dropdown choices come from `nixd`.
Without `nixd`, the app falls back to `nix eval --json`, and options without type
data render as raw text.

## Change a value

Edits are staged in memory. Nothing is written until you save, and closing the
window discards unsaved changes.

Widgets map to Nix values: a switch writes `true` or `false`, a dropdown writes
one of its choices, a spin writes an integer, a slider writes a number, text
writes a quoted string, and a path writes a path literal. A package control
writes a package expression, and a color control writes a `#rrggbb` string.
Collection widgets such as the bar, dock, and monitor editor write structured
attribute sets.

Some controls carry an apply command. When the Apply changes immediately
preference is on, that command runs as the value changes and reaches the running
session. With the preference off, the change waits for a save and a rebuild.
Most values are read by the next activation, not by the running shell.

## Save and rebuild

`Save` writes every dirty control, patches the affected files, checks each
result, formats it, and writes it. If any file fails to parse, nothing is
written and an error appears. Files under `/nix/store` are not writable, so a
store-path control refuses edits.

`Save & rebuild` saves first, then runs the configured rebuild command in a
terminal. If the save fails, the rebuild does not run. The command is stored in
`~/.config/nix-settings-gui/config.json` as `rebuild_command`; the terminal
command is stored beside it. The installer and the setup script write
`nixos-rebuild boot`, so the rebuild becomes the default at the next boot.

If the rebuild action is unavailable, `config.json` has no `rebuild_command`.
Open Configure and write one, or run the rebuild by hand.

## Verify

After `Save`, confirm the write reached the module:

```sh
git -C ~/repos/nix-flake diff
```

Expected: the diff shows only the controls you changed, in the module that
declares them, already formatted. A file that fails the parse check is left
unchanged and the window shows the error. Use the path you selected at the top
of the window when it is not `~/repos/nix-flake`.

## Add a page or an option

`Add file` writes a new module with a generated `@menu` header. Choose a
template kind, a filename, and a directory. In a dendritic flake, `import-tree`
picks the file up without an import edit. A plain flake needs the module added to
its imports, and the app says so.

`Add option` opens a picker of known option paths with autocomplete. After you
choose a path, pick a widget and an initial value. The app writes the `@option`
block and the assignment into the target file, then reformats it.

## Why a control is missing

The scanner binds an `@option` comment to the assignment directly below it. The
assignment must sit in a plain module body or in an attribute set the module
evaluates directly. An annotation inside `lib.mkMerge`, a list literal, `map`,
`forEach`, or `lib.optionalAttrs` is dropped. `lib.mkIf` is supported.

The same restriction applies to option discovery. A value hidden inside a
collection expression may never reach the option tree, so its control is missing
or untyped. Fix the module shape rather than the parser. The template's
limitations document gives the supported and unsupported shapes.

## Limits

The menu validates syntax, formatting, and control types. It does not evaluate
the configuration, test boot, or guarantee that a normal-tier change keeps the
system healthy. Advanced and hidden options are outside that claim. A runtime
change can be discarded by a reload or a rebuild. No session has been recorded
as tested.

## Sources

- [nix-settings-gui usage](https://github.com/ojuny-project/nix-settings-gui/blob/main/docs/usage.md)
- [Scanner limitations](https://github.com/ojuny-project/ojuny-template/blob/main/docs/05-settings-gui-limitations.md)
- [Menu and category model](https://github.com/ojuny-project/ojuny-template/blob/main/docs/02-settings-menu.md)
- [Comment syntax](https://github.com/ojuny-project/nix-settings-gui/blob/main/docs/comment-syntax.md)
