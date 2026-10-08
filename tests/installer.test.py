"""Installer text edits and rollback without touching the actual desktop."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('installer', Path(__file__).resolve().parents[1] / 'scripts/install.py')
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)

class InstallerTest(unittest.TestCase):
    def test_only_our_block_is_removed(self):
        original = 'personal before\n' + installer.BEGIN + 'our binding\n' + installer.END + 'personal after\n'
        self.assertEqual(installer.strip_block(original), 'personal before\npersonal after\n')
        self.assertEqual(installer.strip_block('unrelated'), 'unrelated')

    def test_incomplete_block_refused(self):
        with self.assertRaises(RuntimeError):
            installer.strip_block('before\n' + installer.BEGIN + 'missing end')

    def test_rolls_back_both_files_and_link_on_enable_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / 'config'
            bindings = config / 'hypr/bindings.lua'
            shell = config / 'omarchy/shell.json'
            dest = config / 'omarchy/plugins/renanmt.switch-magic'
            bindings.parent.mkdir(parents=True)
            shell.parent.mkdir(parents=True)
            bindings.write_text('personal bindings\n')
            shell.write_text('{"plugins":[]}\n')
            def fake_run(*args):
                if args[0] == 'hyprctl': return ''
                if args[-1] == 'listPlugins': return '[{"id":"renanmt.switch-magic","enabled":false}]'
                if args[:3] == ('omarchy','plugin','enable'):
                    shell.write_text('partially changed')
                    raise RuntimeError('simulated enable failure')
                return 'ok'
            with patch.multiple(installer, CONFIG=config, BINDINGS=bindings, SHELL=shell, DEST=dest, ROOT=root), patch.object(installer, 'run', side_effect=fake_run), patch.object(installer.subprocess, 'run'), patch('sys.argv', ['install.py']):
                with self.assertRaisesRegex(RuntimeError, 'simulated enable failure'):
                    installer.main()
            self.assertEqual(bindings.read_text(), 'personal bindings\n')
            self.assertEqual(shell.read_text(), '{"plugins":[]}\n')
            self.assertFalse(dest.is_symlink())
            self.assertEqual(len(list((config / 'switch-magic/backups').glob('*/bindings.lua'))), 1)

    def test_managed_checkout_installs_bindings_and_uninstalls_without_deleting_source(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / 'config'
            dest = config / 'omarchy/plugins/renanmt.switch-magic'
            dest.mkdir(parents=True)
            (dest / 'manifest.json').write_text('{}')
            bindings = config / 'hypr/bindings.lua'
            bindings.parent.mkdir(parents=True)
            bindings.write_text('personal bindings\n')
            shell = config / 'omarchy/shell.json'
            shell.write_text('{"plugins":[{"id":"renanmt.switch-magic","customViews":[]}]}\n')
            original = shell.read_text()
            def fake_run(*args):
                if args[0] == 'hyprctl': return ''
                if args[-1] == 'listPlugins': return '[{"id":"renanmt.switch-magic","enabled":true}]'
                if args[-1] == 'state': return '{"error":""}'
                return 'ok'
            with patch.multiple(installer, CONFIG=config, BINDINGS=bindings, SHELL=shell, DEST=dest, ROOT=dest), patch.object(installer, 'run', side_effect=fake_run), patch.object(installer.subprocess, 'run'):
                with patch('sys.argv', ['install.py']): installer.main()
                self.assertIn(installer.BEGIN, bindings.read_text())
                self.assertEqual(shell.read_text(), original)
                self.assertFalse(dest.is_symlink())
                with patch('sys.argv', ['install.py', 'uninstall']): installer.main()
                self.assertNotIn(installer.BEGIN, bindings.read_text())
                self.assertIn('personal bindings', bindings.read_text())
                self.assertTrue((dest / 'manifest.json').is_file())

if __name__ == '__main__': unittest.main()
