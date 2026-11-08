# Recovery

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.

The Recovery page has one switch, **Enable recovery UKI**. It is on by default.

When it is on, Ojuny builds a signed Unified Kernel Image from the current
generation and installs it to the ojuny ESP. A firmware entry named
`Ojuny Recovery` points to it. The entry boots the installed system directly,
without systemd-boot, rEFInd or the loader entries.

Turning the switch off removes the UKI, its service and its firmware entry. It
does not change the primary boot path.

## No-USB recovery

If systemd-boot or rEFInd is broken but the ojuny ESP is intact:

1. Reboot and open the firmware boot menu.
2. Select `Ojuny Recovery`.
3. The UKI boots NixOS.
4. Run `nixos-rebuild boot` to repair the primary bootloader.

The UKI does not protect against a corrupted ojuny ESP. In that case use the
firmware boot-from-file option or a live USB.

## Boot order

The boot order service keeps the Ojuny entries first:

- `Linux Boot Manager` on the ojuny ESP
- `Ojuny Recovery` on the ojuny ESP
- `Windows Boot Manager` on the Windows ESP

If Windows resets the order, boot Ojuny once from the firmware menu and the
service restores it.

## Commands

```console
$ ojuny recovery status
$ sudo ojuny recovery rebuild
$ ojuny bootorder status
$ sudo ojuny bootorder fix
```

## Limits

- The recovery UKI is x86_64 only.
- Secure Boot requires the UKI to be signed with an enrolled key.
- The UKI and the boot order service do not replace a corrupted ojuny ESP.
