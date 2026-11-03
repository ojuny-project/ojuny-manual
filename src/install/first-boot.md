# First boot

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `904c038`, 2026-11-03. The steps describe
> the generated configuration; no first boot has been recorded end to end.

## What this covers

The first login after an attended install, an unattended install, or a template
install: connecting to the network, checking the display and hardware profile,
changing the session, and committing the result. It does not cover the install
itself, recovery from a failed boot, or the full settings reference.

## Log in

Remove the installation media before restarting. At the greeter, select the
Ojuny session and log in with the account created by the installer or the setup
script. The template's greeter is `dux-greeter`; the session starts MangoWM,
then Dux Shell.

If the machine boots to a text login, the graphical session did not start.
Check the display manager page after logging in from a TTY, or read the boot
log. Auto-login is off.

## Connect to the network

Open the control center and select the network widget, or use NetworkManager
directly. The settings menu has a Networking page for NetworkManager, the
firewall, DNS, and WireGuard profiles.

If the `ojuny` command is installed:

```sh
ojuny network open
ojuny network status
```

The command line is incomplete; use the control center when a command is
missing.

An unattended install does not configure Wi-Fi. Connect a cable for the first
boot, then join a wireless network from the control center.

## Check the display

The template starts with two generic monitor rules, `eDP-1` and `HDMI-A-1`.
Replace them with the outputs your machine reports. Open the Display page and
set resolution, refresh rate, scale, and position before tuning the bar, gaps,
or borders.

`SUPER+K` opens the searchable keybind menu. If the screen is unreadable after a
display change, switch to a TTY with `Ctrl+Alt+F2` and edit
`modules/02-core/01-display.nix` in the flake, then rebuild.

## Review the hardware profile

The hardware report is written by `generate-hw` or by the installer. Open the
Hardware profile page. If the detected model is wrong, choose a profile from the
dropdown. Apply the choice without running a root probe:

```sh
cd ~/repos/nix-flake
nix run .#regenerate-hardware -- --profile-only
git add modules/07-system/00-hardware-quirks.nix
```

An unmatched machine writes no `nixos-hardware` import and the command reports
`unmatched`. A machine whose model matches an `unsupported` row writes no import
and the Hardware profile page reports `unsupported`. Unsupported rows are listed
in the coverage table with the state `unsupported`, so `unmatched` means no row
matched at all.

## Open the settings menu

Start `nix-settings-gui` from the application menu. The left pane lists one menu
per annotated page. Use the search field to find a page by name, and the system
only checkbox to hide pages the current host does not import.

Changes are staged until you save. `Save & rebuild` writes the Nix files and
then runs the rebuild command from `~/.config/nix-settings-gui/config.json`.
Without that file, the rebuild action stays unavailable until Configure writes
a command.

Some runtime values carry an apply command and reach the running shell as they
change, when Apply changes immediately is on. Layout edits, bar presets that
need a rebuild, and package changes wait for the next rebuild.

## Set the password and account

`users.mutableUsers` is `false`. The account password is a hash in
`modules/01-users/01-user.nix`, so a runtime `passwd` change is not the
supported path. Change the password on the Users page and rebuild.

A hash in the flake rolls back with the configuration. If you enable mutable
users, account state becomes imperative and does not roll back.

## Change the desktop

The bar, dock, launcher, dashboard, control center, and application menu are
Dux Shell surfaces. The dock is off by default. The theme picker uses the base16
schemes installed by `pkgs.base16-schemes`, and the default is Everforest Dark
Hard. Wallpaper presets are generated from the active palette; a custom image
overrides the preset.

Wallpaper cycling and other session state live in `~/.local/state/dms`, which
stays writable. Generated configuration files are symlinks into the Nix store,
so do not edit them in place.

## Optional: Secure Boot

Secure Boot is available only on UEFI systems that already boot with
systemd-boot. It is not available on a BIOS install with GRUB, and the
installer does not enable it. If Windows or BitLocker is present, export and
confirm the recovery key before enrolling keys. The template's Secure Boot
document gives the key creation, enrollment, and verification steps. Keep a
backup; a bad key or firmware setup can leave the machine unbootable.

## Commit the configuration

The flake is a git repository. Commit after a successful rebuild so the next
change and any patch stay reviewable:

```sh
cd ~/repos/nix-flake
git status
git add -A
git commit -m "configure ojuny"
```

If the install used a prepared template or an origin, push the commit to your
remote. Without an origin, the repository stays local.

## Verify

The session should reach the desktop, `SUPER+K` should open the keybind menu,
and the settings menu should list the pages the host imports. This page records
no transcript of that first boot. Check the boot log and session journal if a
surface is missing.

## Limits

No first boot has been recorded at this commit. Hardware detection is checked
against a profile table, and most listed profiles are untested on Ojuny
hardware. Secure Boot is a manual, best-effort flow with no recovery guarantee.
Unattended installs have no Wi-Fi configuration.

## Sources

- [Host setup and generated files](https://github.com/ojuny-project/ojuny-template/blob/main/docs/03-host-setup.md)
- [Hardware coverage](https://github.com/ojuny-project/ojuny-template/blob/main/docs/hardware-coverage.md)
- [Secure Boot](https://github.com/ojuny-project/ojuny-template/blob/main/docs/06-secure-boot.md)
- [Desktop defaults and keybinds](https://github.com/ojuny-project/ojuny-desktop/blob/main/lib/defaults/mango.nix)
