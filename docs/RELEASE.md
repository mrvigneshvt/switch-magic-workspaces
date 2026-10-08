# Switch Magic v0.2.2

First public release of Switch Magic, a visual Alt+Tab switcher for Omarchy.

## Highlights

- Hold Alt to browse window previews; release to focus your selection.
- Three scopes: current workspace, current monitor, and all workspaces.
- Four built-in layouts plus named custom views and an interactive View studio.
- Live captures, snapshots, selected-live previews, and icons.
- Automatic settings saves, theme-aware styling, and configurable grid limits.

## Install

```sh
omarchy plugin add https://github.com/renanmt/switch-magic --enable
python ~/.config/omarchy/plugins/renanmt.switch-magic/scripts/install.py
```

The second command installs the Alt+Tab bindings and backs up the affected
configuration. Plugin ID: `renanmt.switch-magic`.

Requires Omarchy 4 with its Quickshell shell, Hyprland 0.56+ with Lua, and Python 3.

For source installation, removal, screenshots, and keyboard controls, see the
[README](https://github.com/renanmt/switch-magic#readme).

## Validation and limitations

Model, key-routing, installer, manifest and QML checks passed on Omarchy 4.0.4,
Hyprland 0.56.2, and Quickshell 0.3.1. Hidden or suspended applications may supply
stale or unavailable preview frames. Icons and titles provide a fallback.

The marketplace submission is separate from this release; listing approval is
pending until the marketplace maintainers complete their process.
