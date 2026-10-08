import os
import sys
import stat
import importlib.util
from pathlib import Path
import tempfile
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
spec = importlib.util.spec_from_file_location('migration', Path(__file__).resolve().parents[1] / 'scripts/migrate-bindings.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
class MigrationTest(unittest.TestCase):
    def test_exact_blocks_and_idempotence(self):
        for block in m.BLOCKS:
            with tempfile.TemporaryDirectory() as d:
                config=Path(d); p=config/'hypr/bindings.lua'; p.parent.mkdir()
                original='-- personal before\n'+m.BEGIN+block+m.END+'-- personal after\n'
                p.write_text(original); p.chmod(0o640)
                self.assertTrue(m.migrate(config))
                self.assertEqual(p.read_text(),'-- personal before\n-- personal after\n')
                self.assertEqual(p.stat().st_mode & 0o777,0o640)
                self.assertEqual(next((config/'switch-magic/backups').glob('*/bindings.lua')).read_text(),original)
                self.assertFalse(m.migrate(config))
    def test_backups_are_private_under_permissive_umasks(self):
        for mask in [0o022, 0o000]:
            with self.subTest(umask=oct(mask)), tempfile.TemporaryDirectory() as d:
                config=Path(d); p=config/'hypr/bindings.lua';p.parent.mkdir()
                original=m.BEGIN+next(iter(m.BLOCKS))+m.END
                p.write_text(original);p.chmod(0o600)
                previous=os.umask(mask)
                try:
                    self.assertTrue(m.migrate(config))
                finally:
                    os.umask(previous)
                backup=next((config/'switch-magic/backups').glob('*/bindings.lua'))
                self.assertEqual(backup.read_text(),original)
                self.assertEqual(stat.S_IMODE(backup.stat().st_mode),0o600)
                self.assertEqual(stat.S_IMODE(backup.parent.stat().st_mode),0o700)
                self.assertEqual(stat.S_IMODE(p.stat().st_mode),0o600)

    def test_old_backups_secured_even_without_legacy_bindings(self):
        for bindings in [None, '-- clean config\n']:
            with self.subTest(bindings=bindings), tempfile.TemporaryDirectory() as d:
                config=Path(d); backup=config/'switch-magic/backups/old'
                backup.mkdir(parents=True);backup.chmod(0o755)
                backup.parent.chmod(0o755)
                files=[backup/'bindings.lua',backup/'shell.json']
                for file in files:
                    file.write_text('private original');file.chmod(0o644)
                outside=config/'outside';outside.write_text('untouched');outside.chmod(0o644)
                (backup/'link').symlink_to(outside)
                if bindings is not None:
                    path=config/'hypr/bindings.lua';path.parent.mkdir();path.write_text(bindings)
                self.assertFalse(m.migrate(config))
                for directory in [backup,backup.parent]:
                    self.assertEqual(stat.S_IMODE(directory.stat().st_mode),0o700)
                for file in files:
                    self.assertEqual(stat.S_IMODE(file.stat().st_mode),0o600)
                    self.assertEqual(file.read_text(),'private original')
                self.assertEqual(stat.S_IMODE(outside.stat().st_mode),0o644)
                self.assertFalse(m.migrate(config))

    def test_custom_or_incomplete_blocks_are_untouched(self):
        for text in [m.BEGIN+'custom\n'+m.END,m.BEGIN+'incomplete',m.BEGIN+next(iter(m.BLOCKS))+m.END+m.BEGIN]:
            with tempfile.TemporaryDirectory() as d:
                config=Path(d); p=config/'hypr/bindings.lua'; p.parent.mkdir();p.write_text(text)
                with self.assertRaises(RuntimeError):m.migrate(config)
                self.assertEqual(p.read_text(),text)
    def test_clean_install_does_not_create_files(self):
        with tempfile.TemporaryDirectory() as d:
            self.assertFalse(m.migrate(Path(d)))
            self.assertEqual(list(Path(d).iterdir()),[])
    def test_symlink_is_preserved(self):
        with tempfile.TemporaryDirectory() as d:
            config=Path(d); p=config/'hypr/bindings.lua'; p.parent.mkdir()
            target=config/'saved.lua';target.write_text(m.BEGIN+next(iter(m.BLOCKS))+m.END)
            p.symlink_to(target);m.migrate(config)
            self.assertTrue(p.is_symlink());self.assertEqual(target.read_text(),'')
if __name__=='__main__': unittest.main()
