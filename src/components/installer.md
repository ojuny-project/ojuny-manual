# Installer

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `7680158` in `ojuny-installer` and commit
> `83536b7` in this manual. Recorded 2026-11-03. The ISOs build and the attended
> image boots in QEMU, but no install has been completed.

This chapter covers the install paths, the flake they write, and failed-install
recovery. It does not cover the Calamares page order, the build commands, or the
desktop that starts after first boot.

## Claim

The installer owns one transition: it turns a live image and a target disk into
a flake that the machine can rebuild without the image. Everything after that
belongs to the flake. Attended, unattended, offline, and discovery are variations
on how the transition gets its inputs, not separate systems.

## Mechanism

All paths copy `ojuny-template` to `/home/<user>/repos/nix-flake`, generate the
machine-specific modules, and run `nixos-install --flake`. The attended image
does this through Calamares. Its pages cover template choice, locale, keyboard,
users, git origin, partitioning, summary, install, and finish. The template page
selects a bundled template or a prepared clone and takes a URL, token, and
branch. The git origin page initializes the repository, sets the origin, and
records the commit author. The summary is read only. A failed clone or git setup
stops the install instead of warning and continuing.

The unattended image starts `ojuny-unattended-install` on a console. The service
waits for the disk, checks that it is not mounted, counts down, and wipes it.
`disko` writes a GPT layout with a BIOS boot partition, an ESP, an ext4 root or a
LUKS2-encrypted ext4 root, and optional swap. The flake snapshot is copied, the
hardware data is regenerated, and the flake is committed before `nixos-install`
runs. The installed system keeps the disko layout for later redeployments.

The written flake contains generated modules. Both installers regenerate
`modules/07-system/00-hardware.nix` from the target mounts and
`modules/01-users/01-user.nix` from the account. The attended installer also
writes `modules/07-system/00-host.nix`, which registers the host configuration.
The unattended installer updates an existing `00-host.nix` when the template
ships one and does not create it. That is why the unattended document describes
the user module as the only other generated file.

The online images fetch flake inputs. The offline images carry the full live
system closure, the installed target toplevel and its derivation, the
latest-kernel target, GRUB and EFI tools for BIOS boot, and the shell and locale
packages used at install time. They do not carry the full build-dependency
closure. Target hardware is generated at install time, so the package closure
matches while the final toplevel and initrd are built locally from the offline
store.

The discovery images run `nix-cache-discovery` on port 5055 and point the install
at the local cache. The service waits for a peer and falls back to the normal
substituters when none answers. The persistent image is a different artifact: a
raw disk with a tmpfs root, an ext4 `/persist`, an overlay for `/nix/store` whose
lower layer is `/persist/nix/store`, and `/home` bind-mounted from
`/persist/home`. Only home persists across reboot.

## Limits

The unattended path is destructive by design. It wipes the configured disk after
a countdown and does not ask again. The firmware setting is fixed when the image
is built, so one image does not cover both UEFI and BIOS. The service does not
configure Wi-Fi, so online installs need a wired connection. The target is
`x86_64-linux` only, and the install uses the flake snapshot the image was built
from, not the current template branch.

Offline images trade size for independence. An 8 GB key has about 7.4 GiB
usable, the repository applies a hard check at 8,000,000,000 bytes, and the
offline closure covers the default full system and common install choices.
Unusual hardware modules, out-of-tree drivers, and optional patches still need
network access. Missing paths are fixed by an online install or by building a
new offline image that includes them, not by adding packages on the target.

Credentials have their own costs. The unattended builder hashes the password
before the image is built. LUKS2 is optional and its passphrase is stored on the
live ISO with mode `0600`. The attended flow writes `~/.git-credentials` only for
an HTTPS repository URL with a token, also with mode `0600`; SSH clones get no
helper. None of these choices removes the need to trust the image and the
template.

The persistent image keeps only home. Package installs, updates, and writes to
`/etc`, `/var`, and `/nix/var` are transient. The image is sized at 16G in
`nixos/persistent.nix`, is larger than the live ISOs because the first boot needs
the full store, and is `x86_64` only.

The installer repository records no completed install and no measured install
time. The site records 18 minutes on 2026-11-03 for a Calamares install with
LUKS2 root and XFS on a Ryzen 3 3200U with 24 GB RAM and a 256 GB NVMe SSD. The
installer repository does not reproduce that figure.

## Recovery

An attended clone or git failure stops before `nixos-install` and asks for a
reopen. An unattended failure prints the error, starts a shell on tty1, and does
not reboot. That shell is the recovery point: the target disk may be
partitioned, and the flake may be copied.

After install, recovery moves to the flake and its bootloader. A
generation that does not boot is recovered from the previous one. Remote
paths use `deploy-rs` for a target that already runs NixOS and `nixos-anywhere`
for one that does not. `deploy-rs` uses magic rollback; `nixos-anywhere` uses
kexec and needs SSH and enough memory for the kexec image. The generated
hardware module turns on `ojuny.network.deploy-rs.enable` only on machines
prepared for remote deployment.

## Evidence

The installer README at commit `7680158` states that the ISOs build and the
attended image boots in QEMU, and that no install has been completed. The
attended test file marks every row pending. The unattended file states that no
QEMU run is part of the repository. The offline, persistent, and remote documents
define their own manual matrices and none records a completed run.

## Related

- [Installer repository](https://github.com/ojuny-project/ojuny-installer)
- [Attended install tests](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/attended-install.md)
- [Unattended install](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/unattended-install.md)
- [Offline install](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/offline-install.md)
- [Persistent image](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/persistent-image.md)
- [Remote deployment](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/remote-deployment.md)
- [Troubleshooting](../troubleshooting.md)
