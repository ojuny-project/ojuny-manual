# Updates and rollback

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `904c038`, 2026-11-03. The commands and
> options come from the repository and the CLI man page; no update has been run
> for this chapter.

## What this covers

How to update flake inputs, rebuild the system, use the update checker, and
return to an earlier generation. It does not cover merging upstream template
changes in detail, and it does not describe package-level version selection.

## Update on purpose

Ojuny has no automatic update of packages or flake inputs. Two scheduled jobs do
change the store without a rebuild: `nix.gc.automatic` collects garbage and
`nix.optimise.automatic` hard-links duplicate paths. Neither changes the running
generation. The DMS updater settings and the repo-sync checker are both off or
inert until you enable them.

Packages and the template move independently. Packages and flake inputs move
when you run a flake update. The template moves when you merge upstream into
your fork.

## Update inputs and rebuild

Update one input:

```sh
nix flake update nixpkgs
```

Or update every input with `nix flake update` and no input name. The CLI
wrapper updates one named input and prints a context block:

```sh
ojuny flake update nixpkgs
ojuny flake validate
ojuny flake build
ojuny flake activate-boot
```

The context block records the flake path, host, git revision, Nix version, input
revisions, and the result. `validate` also prints the patch switch and the patch
modules it found. The CLI is incomplete; check `man ojuny`.

`build` evaluates and builds the configuration without switching. `activate-boot`
makes the new generation the default at the next boot and leaves the running
system alone. `activate-now` switches immediately. Use `activate-boot` for a
large update so a failed boot can be caught at the boot menu.

The same steps by hand:

```sh
nixos-rebuild build --flake ~/repos/nix-flake#<host>
sudo nixos-rebuild boot --flake ~/repos/nix-flake#<host>
```

## The update checker

`simple-nix-update-gui` is a repo-sync checker. It keeps an installed system in
step with the remote flake it was built from. It is not a package updater.

The service is disabled by default; enable it on the Updates page. When it runs,
it compares the active system path with the evaluated system derivation for the
configured flake URI and host. A difference means an update exists; package
versions are not read.

The page exposes the flake URI override, the clone path override, a check
interval (30 minutes, 1 hour, 6 hours, 12 hours, or 1 day; default 1 hour),
notifications, `nix-output-monitor` graphing, and tray autostart. A rebuild
clones or pulls the flake as the invoking user, then runs `nixos-rebuild` against
the local path. `build` runs unprivileged; `boot` and `switch` ask for a password
in the embedded terminal.

The shipped DMS updater policy starts no check, sends no notification, and
updates nothing; its advanced keys are on the same page. Enabling one is a
choice, not a supported default.

`nix-monitor` is separate. Its Rebuild button opens `nix-settings-gui`; it does
not rebuild by itself. The monitor reports the launch as complete when that
window closes, not when the build finishes.

## Roll back

Every switch creates a generation. If an update breaks the desktop, reboot,
open the boot menu, and select the previous generation.

From a running terminal, roll back to the previous generation:

```sh
sudo nixos-rebuild switch --rollback --flake ~/repos/nix-flake#<host>
```

Rollback restores system state. It does not restore user files, Flatpak
applications, or an imperative password change. A mutable account survives a
rollback because it is not part of the generation.

Check the active generation:

```sh
nixos-rebuild list-generations
```

Expected: the current generation is the one you rolled back to, and the boot
menu lists the same generations.

Generations disappear when they are garbage collected. Keep at least one known
good generation if you plan to test a large update.

## Garbage collection and the store

`nix.gc.automatic` runs scheduled collection. `nix.gc.dates` sets the calendar
expression, and `nix.gc.options` holds flags such as `--delete-older-than 30d`.
The schedule and options are on the Nix settings page.

`nix-cleaner` is the manual path. It groups store paths by package, lists garbage
collection roots and their generations, and shows the closure and solo savings
for a root. Roots that keep the running system, the booted system, the active
generation, the newest three generations, or an active profile alive are
protected.

The cleaner writes a plan and asks a privileged helper to verify it against a
fresh scan. Cleaning unlinks the selected root links and runs collection through
the `dev.den.nix-cleaner.clean` polkit action with `pkexec`, never `sudo`.

## LAN cache

The Nix settings page has a LAN cache. It is off by default. When enabled, every
host runs the same daemon, serves its own store, finds peers, and proxies paths
it does not have. The port must match on every device; the template uses 5055.
The scan interval defaults to 600 seconds.

With the cache set as the only substituter, the local daemon becomes the trust
boundary and fetches missing paths from the fallback substituters itself. The
cache has no user authentication, so the configured address range is the trust
boundary. The subnet is resolved at startup; restart the service after joining a
network.

## Limits

Ojuny ships no binary cache, so software outside nixpkgs is built locally. Build
time is not measured in this manual. The site records 18 minutes for a Calamares
install with LUKS2 root and XFS on a Ryzen 3 3200U with 24 GB RAM and a 256 GB
NVMe SSD, recorded 2026-11-03. The update checker reports only that the
installed system differs from the remote. Rollback does not cover user data,
Flatpaks, or mutable account state. No update or rollback has been recorded as
tested for this chapter.

## Sources

- [Update tool options and defaults](https://github.com/ojuny-project/ojuny-template/blob/main/modules/02-core/10-updates.nix)
- [ojuny flake commands](https://github.com/ojuny-project/ojuny-cli/blob/main/docs/user.md)
- [simple-nix-update-gui module](https://github.com/ojuny-project/simple-nix-update-gui/blob/main/modules/nixos.nix)
- [Site update overview](https://github.com/ojuny-project/ojuny-project.github.io/blob/main/src/content/docs/configuration/updates.md)
