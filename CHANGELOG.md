# Changelog

## 0.3.2

- Automatically restrict existing backup directories to 0700 and files to 0600 before any migration early return or installer preflight.
- Leave symlink targets outside the backup tree untouched.
- Cover upgrades with an already migrated or missing bindings file and failed installer preflight.


## 0.3.1

- Create configuration backup directories with mode 0700 and backup files with mode 0600.
- Preserve original file permissions during installer rollback using exclusive temporary files.
- Add regression coverage for restrictive originals and permissive process umasks.


## 0.3.0

- Attach shortcuts automatically with the standard Omarchy plugin lifecycle.
- Restore saved bindings on disable, removal, or shell heartbeat expiry.
- Reattach after Hyprland configuration reloads.
- Migrate the legacy marked include automatically, preserving a backup.

## 0.2.2 — First public release

- Visual Alt+Tab switching above fullscreen windows, with workspace, monitor,
  and all-workspace scopes.
- List, Grid, Carousel, and Hand of cards layouts with native window captures.
- Live, snapshot, selected-live, and icon preview modes.
- Named custom views with immutable built-in templates, a visual editor, and
  automatic saving.
- Configurable grid row and column limits with automatic screen fitting.
- Omarchy theme colors, typography, and a scalable Switch Magic logo.
- Backed-up keyboard integration with rollback and removal support.
- Public plugin ID: `renanmt.switch-magic`.

Requires Omarchy 4 / Hyprland 0.56+ with Lua configuration. Adding the plugin
through Omarchy requires the documented one-time shortcut setup.
