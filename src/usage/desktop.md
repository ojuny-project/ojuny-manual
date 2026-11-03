# The desktop

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `34462aa` in `ojuny-desktop` and commit
> `904c038` in `ojuny-template`, 2026-11-03. The modules and the generated
> configuration are described from the code; no desktop session has been
> recorded end to end.

## What this covers

What starts when you log in, which surfaces the shell provides, how to move
windows and find a keybind, and how the configuration reaches the running
session. It does not list every option or every keybind. The options reference
is in the desktop repository, and the keybind menu reads the same definitions as
MangoWM.

## The session

The desktop is one Wayland session built from MangoWM and Dux Shell. MangoWM is
the compositor; Dux Shell runs on top. An X11 session does not work.

The session is registered as `Ojuny Desktop` with id `ojuny`. The template
provides a graphical greeter
through `dux-greeter` and makes the Ojuny session the default. The login page in
the settings menu holds the greeter, compositor, and auto-login options.

Dux Shell needs `quickshell` 0.3.0 or newer. The flake supplies a matching
version and the wrapper checks it at build time.

## Surfaces

The bar is enabled and carries workspaces, a layout indicator, media, clock,
tray, clipboard, a Nix monitor, and a control center button. Island presets
change its shape. The custom bar editor is on the Bar page.

The dock is off by default. The launcher is searchable and has an
app drawer plus triggers for clipboard, power, settings search, and QR
generation. The dashboard is a full-screen overview with cards and tabs. The
control center combines quick tiles and a widget grid. The application menu is
either the shell's own menu or the Nix-managed menu tree.

Notifications, clipboard history, the on-screen display, sounds, the lock
screen, and power controls are always present. The screensaver is an optional
ASCII program that runs before the lock screen and is off by default.

Every surface is configured from the same `desktop.ojuny.*` option tree. The bar,
dock, dashboard, and menu layouts are collection edits, so they need a rebuild
before they appear.

## Windows and workspaces

MangoWM tiles windows. The default layout is `tile`, a master area plus a stack.
The [template Mango defaults](https://github.com/ojuny-project/ojuny-template/blob/904c038/modules/03-desktop/02-mangosettings.nix)
set that default and expose master and stack, dwindle, scroller, and
monocle/deck as separate settings pages. Changing the default is a dropdown in
the settings menu.

Workspaces and tags are the same concept here. A window can sit on more than one
tag, and more than one tag can be visible at once. The workspace page holds tag
names and workspace rules; the master and stack counts have their own layout
pages.

Monitor rules are Nix values. A fresh system has generic `eDP-1` and `HDMI-A-1`
rules so the first session is predictable. The [template display
module](https://github.com/ojuny-project/ojuny-template/blob/904c038/modules/02-core/01-display.nix)
defines them. Replace them with the outputs your machine reports. The display
page exposes position, resolution, refresh rate, scale, tearing, HDR, gamma, and
contrast, and the monitor widget arranges outputs graphically.

## Keybinds

`SUPER+K` opens the searchable keybind menu. It is the one bind worth
memorizing. The menu is grouped by the `group` field on each bind.

Three alternate modes are triggered from the keyboard. The [template
binds](https://github.com/ojuny-project/ojuny-template/blob/904c038/modules/02-core/03-binds.nix)
define these keys and their group-mode actions:

- `SUPER+F1` enters movement mode. WASD moves windows and numbers send them to
  workspaces.
- `SUPER+F2` enters groups mode. WASD joins windows into a group, H and L move
  group focus, Z leaves the group, and numbers toggle workspace visibility.
- `SUPER+F3` enters resize mode. WASD resizes the focused window.

`SUPER+BackSpace` returns to the default mode. Mouse binds, axis binds, and
trackpad gestures use the same structured model. Gestures are trackpad-only.

The keybind cheatsheet is generated from the bind definitions, so it cannot
disagree with the session. Editing a bind means editing the module and
rebuilding, not editing a separate cheatsheet.

## How the configuration is applied

MangoWM reads `~/.config/mango/ojuny.toml`, a stable symlink into the store. The
wrapper passes that path with `-c`. A user-owned `config.toml` or `config.conf`
can sit beside it; the watcher matches exact paths, so only `ojuny.toml`
triggers a reload.

The Dux Shell tree is generated in the store and each file is symlinked into
`~/.config/dms`. The directory stays writable so the shell can create its own
files. The session file is a writable copy in `~/.local/state/dms`.

On NixOS, activation repoints the links during `nixos-rebuild`. The running
shell does not reload by itself.

## Procedure

After a switch, restart the shell:

```sh
ojuny dux restart
```

If the `ojuny` command is not installed, log out and back in. Restarting the
compositor closes every window in the session.

## Verify

`ojuny dux status` runs `dms --version`. Treat it as a version check, not proof
that the shell restarted. Check that a changed setting appears, or that the shell
process is new.

## Default applications

Firefox, Ghostty, and dux-files are default. Terminal binds use
`ojuny-ghostty`, a wrapper that loads the generated Ghostty configuration before
your own file, so your values win. The `ghostty` binary is not replaced.

KDE Connect is enabled as a user service, along with its GVFS and SSH agent
prerequisites. The default Dux Shell plugins are enabled with `mkDefault`
because the default bar, control center, and binds reference them. Disable one
on the Plugins page or override its source.

## Limits

The desktop is one shape: MangoWM with Dux Shell. Other desktops exist only as
patches. The session is Wayland-only. Generated files under `~/.config` are
symlinks into the store, so edits there disappear at the next activation.
Restarting Dux Shell does not reload the compositor. No session has been
recorded as tested, and disk and memory use are not measured.

## Sources

- [Desktop README: modules, install, limits](https://github.com/ojuny-project/ojuny-desktop#readme)
- [Desktop option reference](https://github.com/ojuny-project/ojuny-desktop/blob/main/options.md)
- [Design: generated files and links](https://github.com/ojuny-project/ojuny-desktop/blob/main/DESIGN.md)
- [Default MangoWM keybinds](https://github.com/ojuny-project/ojuny-desktop/blob/main/lib/defaults/mango.nix)
- [Template display rules](https://github.com/ojuny-project/ojuny-template/blob/904c038/modules/02-core/01-display.nix)
- [Template Mango defaults](https://github.com/ojuny-project/ojuny-template/blob/904c038/modules/03-desktop/02-mangosettings.nix)
- [Template keybinds](https://github.com/ojuny-project/ojuny-template/blob/904c038/modules/02-core/03-binds.nix)
