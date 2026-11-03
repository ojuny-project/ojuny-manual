# Template install

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `904c038`, 2026-11-03. The setup script
> exists and its prompts are described in the repository; no full run is
> recorded.

## What this covers

Fork the template, run its setup app on a NixOS machine, answer the prompts, and
decide whether to rebuild. It does not partition a disk, install NixOS, or write
the desktop settings for you. The setup script assumes a working NixOS system
with a bootloader and an existing filesystem layout.

## Before you start

- NixOS already installed and booting on the target machine.
- The `nix-command` and `flakes` experimental features enabled. A fresh NixOS
  install has both off, and `nix run` fails before the script starts with
  `experimental Nix feature 'nix-command' is disabled`.
- `git` on `PATH`, because the script clones your fork.
- `x86_64-linux`. Other systems are unsupported.
- A GitHub fork of `ojuny-template`. The script clones the fork, not the upstream
  repository.
- Enough memory for the optional pre-build, which builds one target at a time to
  limit peak use. The requirement is not measured.

Enable the experimental features in `configuration.nix`, rebuild, and start a new
shell before running the setup app:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

## Fork and run the setup app

Fork the repository on GitHub, then run the app from the upstream flake:

```sh
nix run github:ojuny-project/ojuny-template#setup
```

The script clears the screen and prints the fork instructions. It then asks for
the git URL of your fork, and for a clone location. The default is
`~/repos/nix-flake`. Set `OJUNY_CLONE_DIR` before starting if you want a different
default, or type a path at the prompt. `--branch` or `-b` clones a named branch
instead of the repository default.

The clone path must not exist. The script stops rather than merging into an
existing directory.

After cloning, the script waits for a key press, then runs three generators
against the clone:

1. `generate-hw` writes `modules/07-system/00-hardware.nix` from the current
   machine, and `modules/07-system/facter.json` when `nixos-facter` is available.
2. `generate-user` fills `modules/01-users/01-user.nix` with the account details.
3. `create-new-system` writes `modules/07-system/00-host.nix` and registers
   `nixosConfigurations.<host>`.

The generated files are added to git so the flake can see them. The script then
prints `Your Ojuny configuration is ready in <path>`.

## Answer the account prompts

The account prompts come from `generate-user`. Expect a username (default
`user`), a description or full name, groups (default `networkmanager`, `wheel`,
`video`, and `input`), a shell (default zsh), a password, and optional SSH
authorized keys.
The password is hashed with `mkpasswd`; the plain text is not written to the
flake.

`system.stateVersion` is written once and is not exposed in the settings menu.
`home.stateVersion` is written into the user module. Do not change either value
to match a later release.

## Choose a rebuild

The setup app writes `~/.config/nix-settings-gui/config.json` with the flake
path, the terminal command, and a rebuild command that runs
`nixos-rebuild boot`. It then offers three choices: rebuild and reboot, rebuild
without rebooting, or neither.

A rebuild first builds ten targets one at a time with `--max-jobs 1`, then runs
`nixos-rebuild boot --flake <clone>#<host> --sudo`. The boot rebuild makes the
new generation the default on the next boot and leaves the running system
untouched.

Choosing neither exits without building. The configuration is still complete,
and the settings menu can run the rebuild later.

## Verify

Check that the three generated files exist and that the host is registered:

```sh
ls ~/repos/nix-flake/modules/07-system/00-hardware.nix
ls ~/repos/nix-flake/modules/07-system/00-host.nix
ls ~/repos/nix-flake/modules/01-users/01-user.nix
git -C ~/repos/nix-flake status --short
```

Expected: all three files exist, the host file contains a `nixosConfigurations`
entry, and `git status` is clean or shows only files the script added. The
repository does not record the output of a full run, so the exact result is
unverified.

## If it fails

`setup: no URL given, aborting` means the fork URL prompt was left empty.

`setup: <path> already exists, aborting (remove it or set OJUNY_CLONE_DIR)`
means the clone target is already present. Move or remove the old directory, or
start the app with a different `OJUNY_CLONE_DIR`.

`experimental Nix feature 'nix-command' is disabled` comes from Nix, not the
script. Enable the features, rebuild, and open a new shell.

`setup: could not read the hostname from 00-host.nix, skipping the rebuild
prompt` means `create-new-system` did not write the expected host line. The
script exits 0 after printing the configuration path. Check the host file, then
run the rebuild by hand.

If the hardware probe cannot run, `generate-hw` keeps the existing report
instead of failing. A missing `nixos-facter` therefore produces a hardware
module without the facter report.

## Limits

One flake describes one host. A second machine needs a second fork, or a copy of
the system directory. Partitioning is manual and the generated hardware module
describes the layout that already exists. `generate-hw` writes the `boot.loader`
configuration for the running machine, `systemd-boot` on EFI and `grub` on BIOS,
and NixOS installs that loader during the rebuild. Secure Boot is an optional
post-install step for UEFI with systemd-boot. Disk and memory use are not
measured, and no end-to-end run has been recorded. The pre-build list covers ten
targets, so a target outside that list can still use memory during the rebuild.

## Sources

- [Template README: install and first run](https://github.com/ojuny-project/ojuny-template#readme)
- [Host setup specification](https://github.com/ojuny-project/ojuny-template/blob/main/docs/03-host-setup.md)
- [Setup script](https://github.com/ojuny-project/ojuny-template/blob/main/scripts/setup.sh)
- [Secure Boot](https://github.com/ojuny-project/ojuny-template/blob/main/docs/06-secure-boot.md)
