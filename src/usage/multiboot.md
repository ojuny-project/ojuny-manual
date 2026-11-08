# Multiboot

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.

Multiboot is an optional rEFInd helper. It is off by default. When it is on,
systemd-boot gets one extra entry named "Other systems". That entry starts
rEFInd, which scans the internal drives and shows the other operating systems.

The helper is not installed when the option is off. The attended installer
enables it when it finds another internal system that systemd-boot cannot see on
its own.

## When it is needed

systemd-boot only reads its own ESP and XBOOTLDR partition. Windows on the same
ESP is detected natively. Any other system on another ESP or another internal
disk needs the helper.

Enable it on the Secure Boot page in the settings menu. Turning it off again
removes the rEFInd directory and the "Other systems" entry at the next boot.

## Installing alongside Windows

Windows NTFS is never resized by ojuny. Shrink the Windows partition in Windows
Disk Management before starting the installer, and export the BitLocker recovery
key first when BitLocker is enabled. A forced Linux-side NTFS shrink can leave
Windows unbootable.

The attended installer can shrink XFS, EXT4, BTRFS, f2fs and vfat partitions
and install into the freed space. It does not resize NTFS. The whole-disk and
unattended paths erase the disk and are not dual-boot paths.

Install Windows first. Windows recreates the ESP when it installs and removes a
Linux bootloader installed before it. Do not resize the 200 MiB Windows ESP.
The installer creates a 4 GiB ojuny ESP in the replaced partition and leaves the
Windows ESP unassigned. systemd-boot, rEFInd, the kernels, the initrds and the
recovery UKI live on the ojuny ESP.

## Adding a drive

Detection runs once at boot. After adding an internal drive:

1. Boot ojuny once so the helper scans the new drive.
2. Reboot and select "Other systems".

Check the last scan with:

```console
$ ojuny multiboot status
```

A rescan needs root:

```console
$ sudo ojuny multiboot rescan
```

## Secure Boot and BitLocker

Under Secure Boot the helper must be signed. The service signs it with `sbctl`
when the Lanzaboote keys exist. `ojuny multiboot status` reports the helper as
`signed`, `unsigned`, or `not-required`.

Selecting Windows uses the Windows Boot Manager firmware entry. rEFInd sets
`BootNext` and reboots, so BitLocker keeps its expected measurements. This costs
one visible reboot. The direct Windows chainload entry is hidden when BitLocker
is detected.

Another Linux distribution only starts when its boot loader is signed by a key
the firmware trusts. That is the normal Secure Boot key problem, not something
the helper can bypass.

## Limits

- UEFI only. BIOS uses GRUB with os-prober.
- Two menus: systemd-boot shows "Other systems", then rEFInd shows the targets.
- The helper sees EFI loaders. A Linux installation whose boot loader is not on
  an ESP is not listed.
- External and optical drives are not scanned.
- Lanzaboote measured boot must re-enroll its pcrlock policy after the helper is
  enabled because the boot path changes.
