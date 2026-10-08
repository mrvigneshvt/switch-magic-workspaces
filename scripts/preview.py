#!/usr/bin/env python3
"""Run an isolated development instance with Omarchy's real theme singletons."""
import os
from pathlib import Path
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix='switch-magic-preview-') as tmp:
    path = Path(tmp)
    for name in ['SwitchMagic.qml', 'defaults.json', 'components', 'lib']:
        (path / name).symlink_to(ROOT / name)
    (path / 'Commons').symlink_to(Path(os.environ.get('OMARCHY_PATH', '/usr/share/omarchy')) / 'shell/Commons')
    (path / 'shell.qml').write_text('import Quickshell\nShellRoot { SwitchMagic { registerShortcuts: false } }\n')
    print('In another terminal:', flush=True)
    print(f'quickshell ipc -p {tmp} call -- switch-magic preview fan', flush=True)
    print(f'quickshell ipc -p {tmp} call -- switch-magic cancel', flush=True)
    print(f'quickshell ipc -p {tmp} call -- switch-magic settings', flush=True)
    try:
        subprocess.run(['quickshell', '-p', tmp, '--no-color'], check=True)
    except KeyboardInterrupt:
        subprocess.run(['quickshell', 'kill', '-p', tmp], capture_output=True)
