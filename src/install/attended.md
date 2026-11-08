# Attended ISO install

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `7680158`, 2026-11-03. No attended install
> has been completed, in QEMU or on hardware.

## What this covers

Build the attended Calamares ISO, boot it, complete each installer page, and
check the installed system. It does not cover the unattended image, remote
deployment, or the settings you change after first login.

## Before you start

- An `x86_64-linux` machine with Nix and flakes enabled.
- Network access for the build and for the online image during install.
- A target machine with 4 GB of RAM and a 30 GB disk. The disk is repartitioned
  by the installer.
- An 8 GB USB key. The offline image is checked against 8,000,000,000 bytes.
- A backup of anything on the target disk. Partitioning is destructive.
- For a prepared template, a git URL, and optionally a token and branch.

The installer supports EFI with systemd-boot and BIOS with GRUB; the firmware
mode comes from the machine that boots the ISO.

## Build the ISO

Clone the installer and build the online attended image:

```sh
git clone https://github.com/ojuny-project/ojuny-installer
cd ojuny-installer
nix build .#ojuny-iso
```

The image lands under `result/iso/`. A successful build leaves one `.iso` file
there. Size and build time are unrecorded.

The attended targets are `.#ojuny-iso` for the online image,
`.#ojuny-iso-discovery` for the image that looks for a local cache, and
`.#ojuny-iso-offline` for the full-system image. Build the offline image when the
target has no wired connection.

## Write and boot

Write the ISO to the USB key with Etcher or Rufus. Boot the target machine from
the key. The live session starts the installer as a desktop application.

The installer can be closed without writing anything. Reopen it from the
`Install Ojuny` entry in the application menu.

## The installer pages

The pages are welcome, Ojuny template, locale, keyboard, users, git origin,
partition, and summary. The install runs after the summary, and the finished
page follows it.

The template page asks whether to use the bundled template prepared for the
machine or a prepared `ojuny-template` repository. A prepared repository must
contain `modules/07-system/00-host.nix` with a `nixosConfigurations` entry,
because the installer reads the hostname from that file. The URL, the optional
HTTPS token, and the optional branch are read from this page. An SSH clone uses
your key and gets no credential helper.

The users page creates the account and the hostname. The password is hashed
into the Nix configuration and is never stored as plain text. The default
groups are `users`, `networkmanager`, `wheel`, `video`, and `input`, and the
default shell is zsh. Hostname changes are not taken from this page in prepared
mode.

The git origin page applies only to the bundled template. Leave the URL empty to
keep the installed configuration local, or enter an HTTPS or SSH remote. An
HTTPS remote with a token writes `~/.git-credentials` with mode `0600`. The
initial commit is authored as `Ojuny Installer <installer@ojuny.local>`.

The partition page can use the whole disk or install alongside existing systems.
The whole-disk option erases the selected disk. Alongside mode can shrink XFS,
EXT4, BTRFS, f2fs and vfat partitions automatically. EFI uses a `/boot`
partition with a recommended size of 4 GiB. The default root filesystem is
ext4; btrfs, xfs, and f2fs are available. LUKS2 encryption is optional and
covers the root partition. Swap can be none, small, or suspend-sized.

If Windows is installed, shrink its partition in Windows Disk Management before
starting the installer, and export the BitLocker recovery key first when
BitLocker is enabled. Ojuny does not resize NTFS. The partition page shows this
warning before the disk layout is chosen.

Install Windows first. Windows recreates the EFI system partition when it
installs, so a Linux bootloader installed before Windows is removed. Do not
resize the 200 MiB Windows ESP. The installer creates a 4 GiB ojuny ESP in the
replaced partition and leaves the Windows ESP unassigned. systemd-boot, rEFInd,
the kernels, the initrds and the recovery UKI live on the ojuny ESP.

The summary page is read-only and repeats the account, hostname, bootloader,
disk, template, and repository.

Installation runs `nixos-install --flake` against the copied template. It writes
`modules/07-system/00-hardware.nix`, `modules/01-users/01-user.nix`, and
`modules/07-system/00-host.nix`, then commits the result.

## After the install

Remove the USB key and reboot. Log in with the account from the users page. The
configuration is a git repository at `~/repos/nix-flake`. Continue with
[First boot](first-boot.md).

Verify the generated files:

```sh
ls ~/repos/nix-flake/modules/07-system/00-hardware.nix
ls ~/repos/nix-flake/modules/07-system/00-host.nix
ls ~/repos/nix-flake/modules/07-system/facter.json
ls ~/repos/nix-flake/modules/01-users/01-user.nix
git -C ~/repos/nix-flake log --oneline
git -C ~/repos/nix-flake remote -v
```

Expected: all of these files exist. A bundled install has one commit. A prepared
install keeps the fork history and adds the hardware regeneration commit on top.
A remote appears only if you entered an origin, and a prepared clone keeps its
own remote. No transcript is recorded; treat the output as unverified.

## If it fails

`could not clone the prepared template repository <url>` means the URL, token, or
branch is wrong, or the machine has no route to the host. The install stops
before any system is written. Reopen the installer, correct the template page,
and retry.

`could not read the hostname from the prepared repository` means the repository
has no `nixosConfigurations` entry in `modules/07-system/00-host.nix`. Add the
host entry to the fork, or use the bundled template.

`could not finish the git setup` means the origin remote or token failed after
the system was installed. The installer stops rather than leaving a half
configured repository. Correct the page and retry, or set the remote by hand
after first boot.

If the live session starts but the installer window does not, reopen it from the
`Install Ojuny` entry. If the machine boots to firmware settings instead of the
ISO, check the boot order and write the key again.

## Limits

The attended path has no completed run at this commit. Install time, the exact
Calamares screen layout, and the installed system's first boot are not measured.
The online image needs network; the discovery image needs a peer with the
cache. Secure Boot is not enabled by the installer. There is no Wi-Fi
configuration step in the installer, so use a wired connection for an online
install.

## Sources

- [Attended install tests and pending cases](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/attended-install.md)
- [Installer README: build targets and QEMU](https://github.com/ojuny-project/ojuny-installer#readme)
- [Partition module configuration](https://github.com/ojuny-project/ojuny-installer/blob/main/packages/ojuny-calamares-extensions/config/modules/partition.conf)
- [Offline install images](https://github.com/ojuny-project/ojuny-installer/blob/main/docs/offline-install.md)
