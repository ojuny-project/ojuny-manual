# Unattended ISO install

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `7680158`, 2026-11-03. The build script and
> the install service exist; no unattended install has been completed.

## What this covers

Build an unattended installer from a template, choose the online, offline, or
discovery variant, boot it, and check the result on the target machine. It does
not cover the attended Calamares image or deploying to a machine that already
runs NixOS.

## Before you start

- `x86_64-linux` with Nix and flakes enabled, and network access for the build.
- A target disk identified by its stable path, preferably
  `/dev/disk/by-id/...`. The disk is wiped after a countdown.
- A backup. The install cannot be undone.
- A decision on firmware: EFI or BIOS. The choice is fixed when the ISO is
  built, and the two modes use separate images.
- A template URL, or a local path to a template checkout. Without one, the base
  template is used.
- The account name, password, and optional SSH keys.
- An 8 GB USB key. The offline image is checked against 8,000,000,000 bytes.

Wi-Fi is not configured; use a wired connection for online and discovery.

## Build the image

Run the settings wrapper from the upstream flake:

```sh
nix run github:ojuny-project/ojuny-installer#make-unattended-iso
```

The wrapper shows a variant menu and prompts for the template, disk, firmware,
mode, account, password, and SSH keys. Pressing Enter accepts the template
default and, in bundled mode, the account defaults of `user` on host `ojuny`.
The firmware and mode are select menus, which need a number. The disk prompt
defaults to `/dev/disk/by-id/CHANGE-ME`, which is a placeholder rather than a
disk. Choose the firmware and mode, and replace the placeholder disk with the
target path. Skip the variant menu with one flag:

```sh
nix run github:ojuny-project/ojuny-installer#make-unattended-iso -- --online
nix run github:ojuny-project/ojuny-installer#make-unattended-iso -- --offline
nix run github:ojuny-project/ojuny-installer#make-unattended-iso -- --discovery
```

`--dry-run` prints the settings and the build command without building.
`--template` and `--flake` take the same value, so a fork URL or a local checkout
works without preparing a repository. The ISO is copied to
`./result-unattended/`. The file name and size are not recorded, so check that
the directory contains one `.iso` after the build.

The flake also exposes `.#unattended-iso`, `.#unattended-iso-discovery`, and
`.#unattended-iso-offline` with the default settings. Use the wrapper when the
disk, account, or firmware is not the default.

The settings stay in a temporary flake input; the password is hashed with
`mkpasswd` before the build.

## Write and boot

Write the ISO with Etcher or Rufus and boot the target machine from the key.
The live image boots to a console and starts `ojuny-unattended-install` as a
service.

The service waits for the target disk, checks that it is not mounted, and waits
through `confirmSeconds` before wiping it. The countdown is the last chance to
stop.

## What the install does

`disko` creates a GPT layout with a BIOS boot partition, an EFI system partition,
an ext4 root, and an optional swap partition. With `--encrypt`, the root is
LUKS2-encrypted and the passphrase is stored on the live ISO with mode `0600`.
The configured firmware decides whether the installed system uses systemd-boot
or GRUB.

The flake snapshot is copied to `/mnt/home/<user>/repos/nix-flake`.
`regenerate-hardware` writes the facter report and the hardware data for the
target. The installer replaces `modules/07-system/00-hardware.nix` with a
generic module that carries the disko layout and the bootloader, so the installed
system can reuse the layout for later deployments. The user module is the other
generated file.

The copy becomes a git repository with one commit. Then
`nixos-install --flake /mnt/home/<user>/repos/nix-flake#<host>` installs the
system. The installer writes `~/.config/nix-settings-gui/config.json`, changes
ownership of the flake to the target user, and reboots or powers off according
to `finalAction`.

On failure the service prints the error and starts a shell on tty1. The target
is not rebooted, so the error stays on screen.

## Verify

After the machine restarts, log in with the configured account and check the
flake and the generated files:

```sh
ls ~/repos/nix-flake/modules/07-system/00-hardware.nix
ls ~/repos/nix-flake/modules/07-system/facter.json
ls ~/repos/nix-flake/modules/01-users/01-user.nix
git -C ~/repos/nix-flake log --oneline
nixos-rebuild build --flake ~/repos/nix-flake#<host>
```

Expected: all three files exist, the repository has one commit that the
installer created, and the evaluation succeeds. None of these checks has a
recorded transcript. The repository's own hardware checklist asks for a boot
test, a desktop start, a check that `00-hardware.nix` contains the disko layout,
and a check that `disko`, `deploy-rs`, and `nixos-anywhere` remain installed.

## If it fails

If the service waits for the disk and never starts, the configured path does not
exist or the disk is already mounted. Power off, reconnect the disk, and check
the path against `/dev/disk/by-id/`.

If the discovery variant cannot find a peer, the install continues against the
normal substituters. A slow install on the discovery image is not a failed
install.

If `nixos-install` fails, the target is left partly written and the shell on
tty1 is the only interface. The disk must be wiped and the install repeated.

If the installed system does not boot, check the firmware mode against the mode
chosen at build time. An EFI image on a BIOS-only machine, or the reverse,
cannot boot.

## Limits

No unattended run is recorded at this commit. The hardware checklist has not
been executed, so boot, desktop start, and redeployment are unverified. The
image is `x86_64-linux` only. The offline image is significantly larger than the
online image. Online and discovery need network; offline still needs it for
unusual hardware modules, out-of-tree drivers, and optional patches. Firmware is
fixed at build time.

## Sources

- [Unattended install flow and settings](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/unattended-install.md)
- [Installer README: targets and limits](https://github.com/ojuny-project/ojuny-installer#readme)
- [Offline install images](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/offline-install.md)
