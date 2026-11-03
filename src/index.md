# Ojuny Manual

<!-- unreleased-marker -->
> **Unreleased.** Ojuny is not released. This chapter is unreviewed, may contain placeholders, and is subject to change without notice.


> Status: pending. Applies to commit `83536b7`, 2026-11-03.

This is the long-form guide to Ojuny: installing it, using the desktop, changing
settings, updating, patching, and working from the command line. It expands the
procedures the site summarizes and links to each repository for reference. It
assumes you can open a terminal and read output, but may not know Nix.

## What this covers

How the chapters are organized, what each status word means, and how to read the
book without network access. Option and command references live in the
repository that owns them.

## Reading the chapters

Install chapters follow the order you need them: attended ISO, unattended ISO,
template install, then first boot. Usage chapters cover the desktop, the
settings menu, updates and rollback, patches, and the command line. Each chapter
starts with a status line and the commit it applies to.

`untested` means the code exists and the page describes it, but nobody recorded
a run end to end. Treat commands on an untested page as the intended procedure,
and report what happens if one fails. `pending` describes scheduled work that is
not complete; the command line chapter uses it because parts of the designed
command surface are not implemented.

## Reading offline

The same Markdown builds into an offline package with a terminal reader, a
browser launcher, and a desktop entry. [Reading offline](offline.md) documents
the commands and what to do when neither reader opens.

## Sources

- [ojuny-manual repository](https://github.com/ojuny-project/ojuny-manual)
- [Reading offline](offline.md)
