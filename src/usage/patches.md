# Patches

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: untested. Applies to commit `edc5f6e`, 2026-11-03. The install commands
> have not been run against this commit.

## What this covers

What a patch is, which patches arrive with the template, how to install one from
the registry, enable it, and remove it. It does not teach patch authoring or
list every option a patch adds. The generated catalogue and each module are the
reference.

## What a patch is

A patch is a Nix module stored in a git repository. Installing a patch copies
one module into your flake. It is not a plugin or a package.

The template imports every `patch-*` module under `modules/patches/` while
`ojuny.patches` is enabled. That switch is the `Enable patches` control on the
`System` page. A patch installed without the switch on sits in the tree with its
options declared, but its configuration is skipped.

Seven patches are pre-included: development, docker, flatpak, impermanence,
nixshell, remote desktop, and virtualization. Six of them have a counterpart in
the `ojuny-patches` registry. The pre-included copy and the registry copy are
separate files, and the template copy must be kept in step with the registry.
`patch-impermanence` has no registry counterpart, so the pre-included set does
not mirror the registry. The registry adds patches beyond that set; `list
available` is the authoritative list at the revision you synced.

## Before you install

- `ojuny-patches` on `PATH`. It comes from `ojuny-cli`:

  ```sh
  nix profile install github:ojuny-project/ojuny-cli#ojuny-patches-cli
  ```

- `git`, because the tool clones patch repositories.
- Network access to fetch a repository the first time.
- Write permission on the flake directory, because installation copies a file
  into it.

The registry configuration lives under `$XDG_CONFIG_HOME/ojuny/`. Clones live
under `$XDG_CACHE_HOME/ojuny/patches`.

## Install a patch

Refresh the registry and list what it offers:

```sh
ojuny-patches sync
ojuny-patches list available
```

`sync` clones missing repositories and runs `git pull --ff-only` on the ones it
already has. The optional argument matches a URL or a cache name. `list
available` prints one line per patch with the id, the name, and the repository
label. The registry metadata also carries descriptions and versions.

Choose an ID and install it:

```sh
ojuny-patches install patch-zed
```

Dependencies are installed first, recursively. The copy lands at
`<local_repository>/<patch_directory>/<id>.nix`. The defaults are
`~/repos/nix-flake` and `modules/patches`. Change them with:

```sh
ojuny-patches configure local_repository /path/to/flake
ojuny-patches configure patch_directory modules/patches
```

Installation does not enable the patch, edit its contents, or rebuild. It copies
one file.

## Verify

Check that the file landed in the patch directory:

```sh
ls ~/repos/nix-flake/modules/patches/patch-zed.nix
ojuny-patches list installed
```

Expected: the file exists, and `list installed` names the patch with the state
`installed`. Neither command is recorded as run against this commit.

## Enable and remove

Enable the patch on its page in the settings menu, then rebuild. The installed
module declares the page. The page is named after the patch and sits beside the
other pages, such as `System`, `DMS plugins`, and `Login`. By hand, the switch
has the shape `ojuny.patch.<name>.enable = true;`, but the exact path is set by
the patch, so read the module or its page.

To remove:

1. Turn the patch enable switch off and rebuild. `ojuny.patches` stays on and
   the module stays in the tree, so its option declarations remain. `_gate.nix`
   returns `options` and gates only `config`, so the patch configuration is
   skipped until the module is removed.
2. Run `ojuny-patches remove <id>`.
3. Rebuild once more.

Removing the module while the switch is still on leaves an option without a
declaration, and evaluation fails. `remove` asks for confirmation unless
`--yes` is given.

`reinstall <id>` removes and copies the patch again. It overwrites local edits to
the installed module.

## Inspect a patch

`info <id>` reports the metadata, repository, commit, and install state.
`list installed` reads the local patch directory rather than the registry.

A repository holds one or more patches with this layout:

```text
modules/patches/<id>.nix
<id>/metadata.md
```

Metadata is Markdown with `key: value` lines: `name`, `id`, `description`,
`dependencies`, and `version`. `dependencies` is a comma-separated list of IDs.
Dependencies are checked by file presence, not by version. A missing dependency
installs first. A cycle exits 6, and a missing dependency exits 5.

## Repositories

`ojuny-patches` keeps a repository list in
`$XDG_CONFIG_HOME/ojuny/repos.list`, one URL per line. It is created with the
default registry on first use.

```sh
ojuny-patches repo list
ojuny-patches repo add https://github.com/example/patches
ojuny-patches repo remove https://github.com/example/patches
ojuny-patches sync example
```

Adding a repository makes its patches appear in `list available` after a sync.
Removing a repository does not remove patches already copied into the flake.

## Security

A patch is Nix code evaluated with the privileges of the system configuration.
It can set any option, add packages, enable services, or replace the desktop.
Read the module before installing it. The registry does not review what a patch
does.

Only add repositories you trust. A patch that adds a service runs that service
on your machine.

## Limits

The install commands are untested at this commit. Dependencies carry no version
constraints, so a patch can depend on an API that has changed. Reinstalling
discards local edits. The pre-included set and the registry are separate
sources, so a fix applied to one does not reach the other. Patches are
third-party content and sit outside the project's support boundary.

## Sources

- [ojuny-patches man page](https://github.com/ojuny-project/ojuny-cli/blob/main/src/ojuny-patches-cli/man/ojuny-patches.1.scd)
- [Patch lifecycle and security](https://github.com/ojuny-project/ojuny-cli/blob/main/docs/patches.md)
- [Registry README](https://github.com/ojuny-project/ojuny-patches#readme)
- [Pre-included patch list](https://github.com/ojuny-project/ojuny-template/blob/main/docs/02-settings-menu.md)
