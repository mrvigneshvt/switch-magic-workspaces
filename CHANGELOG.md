# Changelog

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
