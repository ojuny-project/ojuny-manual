# Command line

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: pending. Applies to commit `bd216aa` in `ojuny-cli` and commit
> `83536b7` in this manual. Recorded 2026-11-03. Both binaries are version
> 0.1.0, no tagged release exists, and the install and usage commands were not
> run for this chapter.

This chapter covers what the two command line programs do, which categories
exist, and where the surface is still unfinished. It does not list every
subcommand or option; the man pages own that reference. It does not cover the
settings menu, which is the persistent counterpart to most runtime commands.

## Claim

Ojuny ships two binaries that wrap tools which already own a feature. `ojuny`
translates a category and command into a call to MangoWM, Dux Modular Shell, or a system
service. `ojuny-patches` manages git repositories that publish optional Nix
modules and copies one module into a local flake. Neither binary stores desktop
configuration.

The CLI is incomplete. Parts of the designed command surface are not
implemented, and commands may change. The categories below are what the binaries
expose today, not the full design. If a command from an older document is
missing, the man page is the accurate record.

## Mechanism

`ojuny` starts at `src/ojuny-cli/bin/ojuny` and loads a library directory set by
the package wrapper. Each category is a file under
`src/ojuny-cli/lib/subtrees/`, and the top-level libraries under
`src/ojuny-cli/lib/` provide shared argument handling, discovery, and output.
The dispatcher resolves the category, checks that its backend exists, then
forwards the command.

The backends are named in the man page: `mmsg` for MangoWM, `dms` for Dux Modular Shell
IPC, `nmcli`, `bluetoothctl`, `wpctl`, `playerctl`, `wg`, `systemctl`,
`loginctl`, `nix`, and `nixos-rebuild`. A missing backend exits 3 rather than
falling back to another tool.

The categories are `bar`, `dock`, `layout`, `sound`, `network`, `bluetooth`,
`window`, `workspace`, `flake`, `toggle`, `display`, `media`, `dashboard`,
`island`, `spotlight`, `vpn`, `run`, `dispatch`, `dux`, `dms`, `capture`,
`clipboard`, `notepad`, `keybinds`, `settings`, `system`, `session`, and
`doctor`. `dms` is a deprecated alias that warns and forwards to `dux`. `doctor`
prints diagnostics for the flake, host, patch state, and expected backend tools.

Most categories change the running session only. `flake` is the exception. It
reads the flake path from `--flake`, then `OJUNY_FLAKE`, then the `flake_path`
key in `~/.config/nix-settings-gui/config.json`, then the current Git root. The
host comes from `--host`, the only configured host, or the current hostname.
`flake update` updates the lock file for one input and does not change the
installed system. `validate` runs checks and a dry build, and `build` builds
without switching, so neither changes the installed system. `activate-boot`
writes the new generation to the bootloader without changing the running system.
`activate-now` switches the running system. All five print a context block with
the path, host, Git revision, Nix version, input revisions, and result.

`ojuny-patches` reads a repository list, clones or fast-forwards it under
`$XDG_CACHE_HOME/ojuny/patches`, and stores its settings under
`$XDG_CONFIG_HOME/ojuny/`. `install` copies `<id>.nix` into the local patch
directory and installs dependencies first. `remove`, `reinstall`, `info`,
`sync`, `list`, and `configure` complete the surface. The installed file is one
module; the tool does not edit it, enable it, or rebuild.

The man pages are generated from `ojuny.1.scd` and `ojuny-patches.1.scd` and
installed with the packages. They list every category, command, option, file,
and exit code.

## Limits

Runtime changes are lost on reload or rebuild. A user who sets a bar preset with
`ojuny bar preset` and then switches generation gets the generated value back.
Persistent values belong in the settings menu, and the two surfaces can disagree
until the next rebuild.

The wrapper is only as capable as its backends. Session commands fail or return a
backend error when Dux Modular Shell is not running, and power and session commands may
trigger a polkit prompt. Running them from a root shell is the wrong context.

Only `activate-boot` and `activate-now` change the installed system, and they
delegate that to `nixos-rebuild`. `activate-boot` does not touch the running
system, which makes it the safer step after an uncertain update. `activate-now`
does. Lock updates and validation or build commands stop before installation.

Patch installation is a file copy with no versioning. Dependencies are checked by
file presence, so an older installed module satisfies a dependency that expects a
newer one. A missing dependency exits 5, a cycle exits 6. Patches are Nix code
evaluated with the privileges of the system configuration, so a repository is a
trust decision.

The incomplete surface is its own cost. A command that appears in an old guide
may not exist, and the error is a usage error rather than a message that names
the replacement. No release tag exists, so a pinned URL is the only stable
reference. Disk and memory use are not measured.

## Evidence

`README.md` at commit `bd216aa` marks the project incomplete and untested and
states that the install and usage commands were not run. The flake checks build
each program, run `tests/run.sh`, and verify the man page. The command list above
is taken from the man page source in the same commit, not from a run.

## Consequence

A command is a request to a backend, not a stored setting. When a runtime command
appears to do nothing, check whether the backend is running before changing the
configuration. When a command is missing, check the man page version that the
installed package provides, not an older guide.

## Related

- [`ojuny(1)` man page source](https://github.com/ojuny-project/ojuny-cli/blob/main/src/ojuny-cli/man/ojuny.1.scd)
- [`ojuny-patches(1)` man page source](https://github.com/ojuny-project/ojuny-cli/blob/main/src/ojuny-patches-cli/man/ojuny-patches.1.scd)
- [User guide](https://github.com/ojuny-project/ojuny-cli/blob/main/docs/user.md)
- [Patch lifecycle](https://github.com/ojuny-project/ojuny-cli/blob/main/docs/patches.md)
- [Troubleshooting](../troubleshooting.md)
