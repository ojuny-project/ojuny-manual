# Troubleshooting

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commits `7680158` (installer), `34462aa`
> (desktop), `bd216aa` (CLI) and `5eeb6b5` (site). Recorded 2026-11-03. No entry
> has a recorded run. Every entry below is unverified and comes from the source
> documents.

Entries are grouped by stage. Each gives cause, fix, cost, and the point where
the problem stops being local. Hardware profiles belong to the template's
coverage table.

## Install

### `experimental Nix feature 'nix-command' is disabled`

Cause: flake commands are off in the Nix configuration.

Fix: add `experimental-features = nix-command flakes` to `/etc/nix/nix.conf` or
the NixOS configuration, then start a new shell.

Cost: one rebuild when the setting is in the configuration; a hand edit is lost
on the next switch.

Stop if the setting is active and flake commands still fail. Open an issue with
`nix --version` and the file that sets it.


### The installer cannot fetch inputs

Cause: the online images run `nixos-install --flake`, which downloads the
template inputs. The machine has no route, or the link came up late.

Fix: connect before an online install, or use an offline image.

Cost: the offline image is larger and carries the default system only.

Stop if an offline install reports a missing store path. Open an issue with the
path, image name, and hardware.


## Boot

### The display is broken in QEMU

Cause: plain VGA, QXL, and 2D `virtio-vga` render the Wayland session
incorrectly.

Fix: use `virtio-vga-gl` with `-display gtk,gl=on`.

Cost: the host needs working 3D acceleration, and the guest has no fallback.

Stop if `gl=on` still gives a corrupted or blank session. Open an issue with the
QEMU version, host GPU driver, and guest log.


### Secure Boot left the system unbootable

Cause: this optional UEFI flow can remove the boot path through a wrong key or
firmware change, with no automatic rollback.

Fix: recovery depends on the firmware and backups. Confirm the BitLocker key
before enrolling, and do not use this on a BIOS or GRUB install.

Cost: firmware recovery and possibly a reinstall. User data is at risk when the
disk cannot unlock.

This is already an issue. Open one with firmware version, boot mode, failed step,
and BitLocker state.


## Rebuild

### `error: builder for '/nix/store/...' failed: signal: killed`

Cause: the build ran out of memory, and concurrent jobs multiply the peak.

Fix: build one target at a time and lower the job count, for example
`nixos-rebuild switch --flake .#<host> --cores 2`.

Cost: a longer build. The specification in `ojuny-docs`
(`documentation/02-spec.md`) describes the penalty as roughly double; the manual
has not measured that number.

Stop if the build is killed with `--cores 1` above the 4 GB minimum. Open an
issue with `journalctl -u nix-daemon`.


### A rebuild fails after an update

Cause: an updated input changed a module, package, or option the host uses.

Fix: boot the previous generation, run `ojuny flake validate` and
`ojuny flake build`, then revert the commit or pin the changed input.

Cost: one generation and time to re-download the reverted inputs.

Stop if validation fails with the input pinned and no local edits. Open an issue
with the output and input revision.


## Desktop

### The display layout is wrong

Cause: the generated default resolution, refresh rate, scale, or position does
not match the monitor.

Fix: set those four values in the display settings before tuning gaps, borders,
or the bar.

Cost: a session reload. The values persist only when written back to the
configuration.

Stop if the settings do not apply after reconnecting the monitor. Open an issue
with `ojuny display list` and the monitor model.


### The theme does not change

Cause: the palette changed in the running shell, or the generated files were
rebuilt without restarting their readers.

Fix: change `ojuny.style.palette`, rebuild, then restart Dux Modular Shell and MangoWM.

Cost: a restart, because both read the configuration at startup.

Stop if the link in `~/.config/dms` points at the new store path and the shell
shows the old palette. Open an issue with the generation.


## Updates

### The update GUI does not update packages

Cause: `simple-nix-update-gui` checks whether the flake repository moved; it is
not a package updater. It and the DMS updater are off by default. Rebuild in
`nix-monitor` opens `nix-settings-gui`, which rebuilds only when its config
contains `rebuild_command`.

Fix: run `ojuny flake update <input>` or `nix flake update`, then rebuild.

Cost: a manual step and a rebuild. There is no auto-update.

Stop if the update succeeds and the rebuild fails; use the rebuild entry.


### A rollback did not restore everything

Cause: a rollback restores system state. It does not restore user files,
Flatpaks, or runtime passwords with mutable users.

Fix: restore user data from backup, roll back Flatpaks separately, and set the
password in the configuration.

Cost: manual work per item. Unbacked data cannot be recovered.

Stop if the system generation is not restored. Open an issue with both generation
numbers and the bootloader entry.


## Patches

### A patch is installed but nothing changed

Cause: installation copies one module. It does not enable the patch, and patches
are disabled by default.

Fix: enable the patch in the settings menu under Patches, then rebuild.

Cost: a rebuild.

Stop if the module is enabled, imported, and still has no effect. Open an issue
with the patch ID and `ojuny-patches info <id>`.


### `ojuny-patches install` exits 5

Cause: a dependency is missing. Dependencies are checked by file presence in the
local patch directory, not by version.

Fix: run `ojuny-patches sync`, then `list installed` and `info <id>`, and install
the missing patch first.

Cost: another patch and one more rebuild.

Stop if the dependency file is present and the command still exits 5. Open an
issue with the metadata and installed list.


## Limits

Patches are third-party Nix code evaluated with system privileges. Remove a
patch you do not trust and report the problem to its repository. Disk failure,
firmware bugs, and unsupported hardware are out of scope.

## Sources

- [Installer](https://github.com/ojuny-project/ojuny-installer)
- [Desktop design](https://github.com/ojuny-project/ojuny-desktop/blob/main/DESIGN.md)
- [Short site entries](https://github.com/ojuny-project/ojuny-project.github.io/blob/main/src/content/docs/troubleshooting.md)
