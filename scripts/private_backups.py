"""Restrict Switch Magic's existing backups without following symbolic links."""
import os
import stat


def secure_existing_backups(config):
    root = config / 'switch-magic/backups'
    try:
        fd = os.open(root, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    except FileNotFoundError:
        return
    try:
        _secure_directory(fd)
    finally:
        os.close(fd)


def _secure_directory(fd):
    # Restrict access before inspecting children, including under umask 000.
    os.fchmod(fd, 0o700)
    for name in os.listdir(fd):
        mode = os.stat(name, dir_fd=fd, follow_symlinks=False).st_mode
        if stat.S_ISLNK(mode):
            continue
        if stat.S_ISDIR(mode):
            child = os.open(name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            try:
                _secure_directory(child)
            finally:
                os.close(child)
        elif stat.S_ISREG(mode):
            child = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=fd)
            try:
                if stat.S_ISREG(os.fstat(child).st_mode):
                    os.fchmod(child, 0o600)
            finally:
                os.close(child)
