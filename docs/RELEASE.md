# Switch Magic v0.3.1

Fixes the backup permissions issue found during marketplace review.

- Configuration backups are private from creation: directories 0700, files 0600.
- Installer rollback preserves original file permissions using exclusive temporary files.
- Regression tests cover restrictive originals, failed installation, and permissive umasks.

Automatic shortcuts and standard Omarchy installation continue to work as in 0.3.0:

```sh
omarchy plugin add https://github.com/renanmt/switch-magic --enable
```

Existing users: `omarchy plugin update renanmt.switch-magic`.

Disable or uninstall restores saved shortcuts automatically.
