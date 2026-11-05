# Command line

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: pending. Applies to commit `bd216aa`, 2026-10-31. Both programs build,
> but parts of the designed command surface are not implemented.

## What this covers

The two command line programs, `ojuny` and `ojuny-patches`: how to install them,
which commands the binaries expose today, how the flake path is found, and what
the exit codes mean. It is not the full reference. The man pages list every
category, subcommand, option, and exit code, and this chapter points at them
instead of copying the tables.

## Status of the command line

`ojuny` and `ojuny-patches` are version 0.1.0 and have no tagged release. The
flake checks build both programs, run the test script, and verify the man pages.

The CLI is incomplete. Parts of the designed surface are missing, and commands
may change. The list in this chapter and the man pages are the accurate record
of what the binaries expose at this commit. A command from an older document
that is not in the man page should be treated as absent.

## Install

Install both packages into your Nix profile:

```sh
nix profile install github:ojuny-project/ojuny-cli#ojuny-cli
nix profile install github:ojuny-project/ojuny-cli#ojuny-patches-cli
```

Check the version and open the manual:

```console
$ ojuny --version
ojuny 0.1.0
$ ojuny-patches --version
ojuny-patches 0.1.0
$ man ojuny
```

The version output above is recorded in the repository README. If `man ojuny`
reports no manual entry, check that `$XDG_DATA_DIRS` includes the profile that
holds the package.

## Requirements

- Linux with Nix and flakes for installation from the flake.
- A running Dux Modular Shell session for the categories that control the shell, such as
  window, workspace, bar, and dock.
- NixOS for `ojuny flake activate-boot` and `ojuny flake activate-now`, which
  call `nixos-rebuild`.
- `git` for `ojuny-patches`.
- `systemctl` and `loginctl` for power and session commands. Polkit may ask for
  authentication. Do not run those commands from a root shell.

Disk and memory use are not measured.

## What the programs do

`ojuny` maps a short command to the tool that already owns the feature. It calls
`mmsg`, `dms`, `nmcli`, `bluetoothctl`, `wpctl`, `playerctl`, `wg`,
`systemctl`, `loginctl`, `nix`, and `nixos-rebuild` as needed. It does not keep
configuration and does not edit Nix files.

The man page groups the commands by category: bar, dock, layout, sound, network,
bluetooth, window, workspace, flake, toggle, display, media, dashboard, island,
spotlight, vpn, run, dispatch, dux, dms, capture, clipboard, notepad, keybinds,
settings, system, session, and doctor. The `dms` category is a deprecated alias
for `dux`; it prints a warning and forwards the command.

Examples that the man page lists:

```sh
ojuny window float
ojuny workspace view 2
ojuny flake validate
ojuny flake activate-boot
```

The `flake` category is the exception to the runtime-only rule. It changes the
system through Nix and prints a context block with the flake path, host, git
revision, Nix version, input revisions, and result. `validate` also reports the
patch switch and the modules it found.

## Runtime settings and persistence

Most commands change the running session only. A reload or a rebuild can discard
the change. Persistent values belong in the settings menu. These commands open
a Dux Modular Shell settings page, not the Nix settings window:

```sh
ojuny settings open bar
ojuny settings open displays
ojuny settings open network
```

A command that opens a page does not save a value. Set the value in the page, or
edit the module and rebuild.

## How the flake is found

The `flake` category resolves its path in this order:

1. `--flake <path>`
2. `OJUNY_FLAKE`
3. `flake_path` in `~/.config/nix-settings-gui/config.json`
4. The current git root, if it contains `flake.nix`

The host comes from `--host`, the only configured host, or the current
hostname. If the context block names a host or path you did not expect, pass
`--flake` and `--host` explicitly.

`--yes` skips prompts. `--dry-run` is accepted but no command reads it, so it
has no effect yet.

## Exit codes

The man page defines six codes:

| Code | Meaning |
| ---: | --- |
| 0 | Success |
| 2 | Usage error |
| 3 | Missing dependency |
| 4 | Backend failure |
| 5 | Validation failure |
| 6 | Conflict |

A script that checks `$?` can tell a usage mistake from a backend failure. The
`ojuny-patches` man page uses the same codes except that 4 is not listed.

## Diagnostics

```sh
ojuny doctor
```

`doctor` checks the flake, the host, the patch state, and the expected backend
tools. It prints diagnostics; it does not repair anything.

## Patches

`ojuny-patches` is the second binary. It syncs patch repositories, lists
available and installed patches, installs one module, and removes it. It is
documented in [Patches](patches.md) and in `man ojuny-patches`.

## Limits

The command line is incomplete. A missing category or subcommand is a known gap
in the software, not a mistake in this page. Commands that change the running
session can be undone by a reload or rebuild. Power and session commands depend
on polkit and on a user session; a root shell is not the supported place to run
them. The programs are untested at this commit, and installation from the flake
was not run for this rewrite. Disk and memory use are not measured.

## Sources

- [ojuny man page](https://github.com/ojuny-project/ojuny-cli/blob/main/src/ojuny-cli/man/ojuny.1.scd)
- [ojuny CLI README](https://github.com/ojuny-project/ojuny-cli#readme)
- [Flake discovery and exit codes](https://github.com/ojuny-project/ojuny-cli/blob/main/docs/user.md)
- [ojuny-patches man page](https://github.com/ojuny-project/ojuny-cli/blob/main/src/ojuny-patches-cli/man/ojuny-patches.1.scd)
