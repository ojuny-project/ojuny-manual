# Desktop layer

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `34462aa` in `ojuny-desktop` and commit
> `83536b7` in this manual. Recorded 2026-11-03. No end-to-end install is
> recorded.

This chapter covers how the desktop layer turns Nix options into MangoWM and
Dux Modular Shell configuration, and where that control stops. It does not cover
individual options, which the repository reference lists, or the settings menu,
which is a separate user surface.

## Claim

The desktop layer is a generator, not a fork. It renders the native
configuration of MangoWM and Dux Modular Shell from one option tree under
`desktop.ojuny.*`, then links the generated files into the paths both programs
already read. A desktop change is therefore a Nix change: it is reviewed,
built, and activated like any other part of the system.

## Mechanism

The shared option definitions live in `lib/ojuny-options.nix` and are imported by
both the NixOS and Home Manager modules, so the two entry points accept the same
tree. `lib/mk-config.nix` turns those values into the output documents:
`mangoToml`, `duxJson`, the clipboard settings, the keybind cheatsheet, and the
plugin settings. Two helpers do the rendering: `lib/to-toml.nix` writes ordered
TOML for the Mango schema, and `lib/to-binds.nix` converts bind groups into both
TOML bind tables and cheatsheet JSON.

`lib/mk-ojuny.nix` builds the store paths and returns the values the modules
consume: `mangoConfigFile`, `duxConfigDir`, `configLinks`, and the wrapper
derivations. The generated Mango file is a stable link at
`~/.config/mango/ojuny.toml`, and the wrapper launches `mango -c` against it.
The link sits beside any user-owned `config.toml` or `config.conf`, so the two
formats do not overwrite each other.

Dux Modular Shell receives a different treatment. Its generated files, including
`config.d/00-ojuny.json`, `clsettings.json`, `cheatsheets/binds.json`, and
`plugin_settings.json`, are linked individually into `~/.config/dms`. That
directory stays real and writable because Dux Modular Shell creates its own files there.
`lib/mk-linker.nix` writes `ojuny-config`, which creates the links, seeds
`session.json`, touches the first-launch marker, and clears a stale
`DankMaterialShell` link.

On NixOS, a user `ojuny-config` oneshot with `restartTriggers` handles every
user. On Home Manager, `xdg.configFile` places the same links and an
`ojuny-config --seed` service runs as the user. The Mango wrapper calls
`ojuny-config --links-only` before starting the compositor. The Dux Modular Shell wrapper
seeds the session file on `dms run`, supplies the runtime path, and asserts that
`quickshell` is at least 0.3.0.

## What it owns

The layer owns the option schema and its defaults, the generated TOML and JSON,
the link map, and the wrappers that launch the session. It also owns the session
package, portals and MIME defaults, the default application list, the plugin
registry defaults, file manager selection, Stylix colour mapping, wallpaper
handling, the dankMenu tree, and the generated Ghostty configuration.

## What it does not own

It does not own MangoWM or Dux Modular Shell source, their command surfaces, or the
runtime state the shell writes. It does not own the user's existing Ghostty
configuration, which loads after the generated file and wins. It does not own
hardware, the bootloader, accounts, or patch selection, and it does not manage
the consumer's system nixpkgs. Importing the module and setting
`desktop.ojuny.enable` remain the caller's decisions.

## Limits

The generated files are store paths, so editing `~/.config/dms/00-ojuny.json` or
`ojuny.toml` by hand changes the running system only until the next activation.
The supported change is an option plus a rebuild. That is the main tradeoff:
readability and reproducibility in exchange for a slower edit cycle.

Because links are placed at activation, a rebuilt configuration is not live until
Dux Modular Shell and MangoWM restart. The Mango watcher matches events by exact path, so
changes to `ojuny.toml` reload the compositor, while a rebuild that repoints the
link still needs the wrapper path to be re-read.

The wrappers do not replace the underlying binaries. `ojuny-ghostty` loads the
generated config before the user file, but the raw `ghostty` binary still exists
and bypasses it. Likewise, options that the layer does not expose require the
raw `mango.global`, `mango.binds`, or `dux.settings` attributes, or they are not
reachable at all.

`ojuny-desktop` carries its own `nixpkgs` pin and the rest of its inputs follow
it. A consumer that leaves that pin unfollowed builds the shell stack against the
desktop flake's nixpkgs, which can differ from the system's. The cost is a second
evaluation and the chance of a module expecting a different nixpkgs revision.

No performance, memory, or install-time figure has been measured. The repository
states that no end-to-end install is recorded, so the costs above are structural.

## Evidence

The generation and linking model is described in `DESIGN.md` in the
`ojuny-desktop` repository, at commit `34462aa`. The module split, the wrapper
assertion, and the rename from `desktop.ojuny.dms.*` to `desktop.ojuny.dux.*`
are in the same repository. The manual has not built or run the session.

## Consequence

A broken generated configuration should fail at build or activation, not after a
hand edit. Diagnosis compares the store path that the link points to with the
settings the running shell reports. A difference means activation or restart has
not completed, not that the option was ignored.

## Related

- [Desktop options reference](https://github.com/ojuny-project/ojuny-desktop/blob/main/options.md)
- [Desktop repository](https://github.com/ojuny-project/ojuny-desktop)
- [Troubleshooting](../troubleshooting.md)
- [MangoWM](https://github.com/mangowm/mango)
- [Dux Modular Shell](https://github.com/duxlabs-dev/dux-shell)
