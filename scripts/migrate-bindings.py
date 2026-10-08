#!/usr/bin/env python3
"""Remove only the exact marked shortcut include installed by Switch Magic <0.3."""
import datetime
import os
from pathlib import Path
import tempfile

BEGIN = '-- BEGIN SWITCH MAGIC\n'
END = '-- END SWITCH MAGIC\n'
EXPRESSION = '(os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))'
BLOCKS = {f'dofile({EXPRESSION} .. "/omarchy/plugins/{name}/bindings.lua")\n'
          for name in ['local.switch-magic', 'renanmt.switch-magic']}

def migrate(config):
    path = (config / 'hypr/bindings.lua').resolve()
    if not path.exists():
        return False
    original = path.read_text()
    if BEGIN not in original:
        return False
    before, rest = original.split(BEGIN, 1)
    if END not in rest:
        raise RuntimeError('The old Switch Magic block is incomplete; left unchanged.')
    block, after = rest.split(END, 1)
    if block not in BLOCKS or BEGIN in after:
        raise RuntimeError('The old Switch Magic block was customized; left unchanged.')
    backup = config / 'switch-magic/backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f-auto-bindings')
    backup.mkdir(parents=True)
    (backup / 'bindings.lua').write_text(original)
    with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, prefix='.switch-magic-', delete=False) as file:
        temporary = Path(file.name)
        file.write(before + after)
    try:
        temporary.chmod(path.stat().st_mode & 0o777)
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)
    return True

if __name__ == '__main__':
    import sys
    try:
        config = Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config')))
        print('migrated' if migrate(config) else 'clean')
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
