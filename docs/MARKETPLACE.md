### Repository URL

https://github.com/renanmt/switch-magic

### Category

Productivity

### Tags

hyprland, quickshell, workspaces

### Suggest a missing tag

_No response_

### Maintainer notes

Switch Magic is a visual Alt+Tab switcher with four built-in layouts, live or
snapshot previews, and a custom view editor. Permanent plugin ID:
`renanmt.switch-magic`. Version: `0.2.2`.

Please mark this listing as requiring manual setup. After `omarchy plugin add
https://github.com/renanmt/switch-magic --enable`, the user must run
`python ~/.config/omarchy/plugins/renanmt.switch-magic/scripts/install.py` to
install the Alt+Tab bindings. This explicitly invoked script backs up the
configuration, adds a marked block, validates it, and rolls back on failure.
Removing the bindings before removing the plugin is documented in the README.

Requires Omarchy 4 with Quickshell and Hyprland 0.56+ Lua configuration, plus
Python 3 for shortcut setup. The plugin captures Wayland toplevels, focuses the
selected window through Hyprland, and saves only its inline shell settings.
It does not write window captures to disk or request elevated privileges.

The root preview and README screenshots use fictional content rendered by the
actual UI in an isolated session. Fresh installations include only four default
views. License: MIT.

### Submission checklist

- [ ] The repository is public and contains installation and removal instructions.
- [ ] I have documented the plugin license and any external dependencies.
- [ ] I confirm that I own or have permission to submit this plugin and its preview assets.
- [ ] The plugin does not overwrite user configuration without explicit consent.
- [ ] I understand that approval is for listing and is not a security review.
