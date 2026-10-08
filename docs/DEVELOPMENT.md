# Development

```sh
python scripts/check.py
# or behavior tests only (Node + Lua, no npm dependencies):
npm test
```

The project separates pure selection/layout logic (`lib/Model.js`), capture
cards (`components/WindowCard.qml`), preferences UI, the Omarchy service
(`SwitchMagic.qml`), and a small compositor key-release bridge (`bindings.lua`).
The four geometry algorithms are implemented in JS; their properties are
JSON-defined. Adding a fundamentally new layout requires a geometry algorithm
and a corresponding editor field entry. JSON specifies properties; it does
not execute code. Regenerate the schema with `node scripts/schema.cjs` after
changing the shared field catalogue.

After editing QML in a symlinked development checkout, run `omarchy restart shell`
if the host retains cached components. Settings edits reload without a restart.

For isolated development, run `python scripts/preview.py`. It loads Omarchy's
theme in a temporary harness without registering global shortcuts, so the
installed plugin can remain active. Use the printed IPC commands to open a
preview or preferences. The preview harness cannot save settings.

```sh
# Show a layout using real windows without switching focus; Esc closes it.
omarchy-shell switch-magic preview fan
omarchy-shell switch-magic cancel

# Inspect runtime state / configuration errors:
omarchy-shell switch-magic state
hyprctl configerrors
```

Developer previews can show private window content. Keep captures of personal desktop content out of commits. The README
screenshots use fictional windows in an isolated rendering session. [VALIDATION.md](VALIDATION.md) records the checks performed for this build.


[← Back to Switch Magic](../README.md)
