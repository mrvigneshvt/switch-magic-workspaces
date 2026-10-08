#!/usr/bin/env python3
"""Install/uninstall a development symlink; preserve unrelated user settings."""
import argparse
import datetime
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
PLUGIN_ID = 'renanmt.switch-magic'
DEST = CONFIG / 'omarchy/plugins' / PLUGIN_ID
BINDINGS = CONFIG / 'hypr/bindings.lua'
SHELL = CONFIG / 'omarchy/shell.json'
BEGIN = '-- BEGIN SWITCH MAGIC\n'
END = '-- END SWITCH MAGIC\n'

def run(*args):
    result = subprocess.run(args, text=True, capture_output=True)
    if result.returncode:
        raise subprocess.CalledProcessError(result.returncode, args, result.stdout, result.stderr)
    return result.stdout.strip()

def strip_block(text):
    if BEGIN not in text:
        return text
    before, rest = text.split(BEGIN, 1)
    if END not in rest:
        raise RuntimeError('Incomplete Switch Magic block; refusing to alter bindings.lua')
    return before + rest.split(END, 1)[1]

def atomic(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.switch-magic-tmp')
    tmp.write_text(text)
    tmp.replace(path)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['install', 'uninstall'], nargs='?', default='install')
    args = parser.parse_args()
    if not BINDINGS.is_file():
        raise RuntimeError('Omarchy 4 / Hyprland Lua bindings.lua is required')
    if DEST.exists() or DEST.is_symlink():
        if DEST.resolve() != ROOT:
            raise RuntimeError(f'{DEST} already exists and is not this project; nothing changed')
    run('omarchy-shell', 'shell', 'ping')
    current_errors = run('hyprctl', 'configerrors')
    if current_errors:
        raise RuntimeError('Fix existing Hyprland config errors before installing: ' + current_errors)
    if args.action == 'install':
        run('omarchy', 'plugin', 'validate', str(ROOT))
    originals = {p: p.read_text() if p.exists() else None for p in [BINDINGS, SHELL]}
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup = CONFIG / 'switch-magic/backups' / stamp
    backup.mkdir(parents=True)
    for path, content in originals.items():
        if content is not None:
            (backup / path.name).write_text(content)
    was_linked = DEST.is_symlink()
    managed_checkout = DEST.exists() and not was_linked and DEST.resolve() == ROOT
    try:
        bindings = strip_block(originals[BINDINGS])
        if args.action == 'install':
            DEST.parent.mkdir(parents=True, exist_ok=True)
            if not was_linked and not managed_checkout:
                DEST.symlink_to(ROOT, target_is_directory=True)
            catalog = json.loads(run('omarchy-shell', 'shell', 'listPlugins'))
            if not any(p.get('id') == PLUGIN_ID for p in catalog):
                run('omarchy-shell', 'shell', 'rescanPlugins')
            for attempt in range(50):
                catalog = json.loads(run('omarchy-shell', 'shell', 'listPlugins'))
                if any(p.get('id') == PLUGIN_ID for p in catalog):
                    break
                time.sleep(.1)
            else:
                raise RuntimeError('Omarchy did not discover the plugin')
            if not any(p.get('id') == PLUGIN_ID and p.get('enabled') for p in catalog):
                for attempt in range(15):
                    try:
                        run('omarchy', 'plugin', 'enable', PLUGIN_ID)
                        break
                    except subprocess.CalledProcessError as exc:
                        detail = (exc.stderr or '') + (exc.stdout or '')
                        if attempt == 14 or not any(message in detail for message in ['not known', 'not responding']):
                            raise
                        # File discovery and the plugin watcher can overlap.
                        # Enabling is idempotent; wait for the registry to settle.
                        time.sleep(.2)
            # Source only our marked block; never rewrite the packaged defaults.
            config_expr = '(os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))'
            block = 'dofile(' + config_expr + ' .. "/omarchy/plugins/' + PLUGIN_ID + '/bindings.lua")\n'
            atomic(BINDINGS, bindings.rstrip() + '\n\n' + BEGIN + block + END)
        else:
            atomic(BINDINGS, bindings)
            run('omarchy', 'plugin', 'disable', PLUGIN_ID)
            if DEST.is_symlink():
                DEST.unlink()
        run('hyprctl', 'reload')
        errors = run('hyprctl', 'configerrors')
        if errors:
            raise RuntimeError('Hyprland rejected the bindings: ' + errors)
        if args.action == 'install':
            # Registration is asynchronous. A short bounded wait verifies the
            # service really loaded before claiming installation succeeded.
            for attempt in range(30):
                try:
                    state = json.loads(run('omarchy-shell', 'switch-magic', 'state'))
                    if state.get('error'):
                        raise RuntimeError(state['error'])
                    break
                except subprocess.CalledProcessError:
                    time.sleep(.1)
            else:
                raise RuntimeError('Switch Magic did not register its IPC service')
        print(f'Switch Magic {args.action} complete. Backups: {backup}')
    except Exception:
        for path, content in originals.items():
            if content is None:
                path.unlink(missing_ok=True)
            else:
                atomic(path, content)
        if not was_linked and DEST.is_symlink():
            DEST.unlink()
        elif was_linked and not DEST.exists():
            DEST.symlink_to(ROOT, target_is_directory=True)
        subprocess.run(['omarchy-shell', 'shell', 'rescanPlugins'], capture_output=True)
        subprocess.run(['omarchy-shell', 'shell', 'reloadConfig'], capture_output=True)
        subprocess.run(['hyprctl', 'reload'], capture_output=True)
        raise

if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        detail = (getattr(exc, 'stderr', '') or getattr(exc, 'stdout', '') or '').strip()
        print(f'Switch Magic: {exc} {detail}', file=sys.stderr)
        sys.exit(1)
