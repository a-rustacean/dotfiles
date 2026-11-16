
#!/usr/bin/env python3

import json
import os
import argparse
from pathlib import Path


def create_symlinks(config_file, force=False, dry_run=False):
    config_file = Path(config_file).resolve()
    repo_dir = config_file.parent

    with config_file.open("r", encoding="utf-8") as f:
        links = json.load(f)

    for source, destination in links.items():
        src = (repo_dir / source).resolve()
        dst = Path(os.path.expandvars(
            os.path.expanduser(destination)
        ))

        if not src.exists():
            print(f"[SKIP] Source does not exist: {src}")
            continue

        if dst.is_symlink() and dst.resolve() == src:
            print(f"[OK]   Already linked: {dst}")
            continue

        if dst.exists() or dst.is_symlink():
            if not force:
                print(f"[SKIP] Destination exists: {dst}")
                continue

            if dry_run:
                print(f"[DRY]  Would remove: {dst}")
                continue

            if dst.is_dir() and not dst.is_symlink():
                print(f"[SKIP] Refusing to replace directory: {dst}")
                continue

            dst.unlink()

        if dry_run:
            print(f"[DRY]  {dst} -> {src}")
            continue

        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.symlink_to(src, target_is_directory=src.is_dir())

        print(f"[LINK] {dst} -> {src}")


def main():
    parser = argparse.ArgumentParser(
        description="Create symlinks for dotfiles."
    )

    parser.add_argument(
        "-c", "--config",
        default="links.json",
        help="Path to links.json"
    )

    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Replace existing files or symlinks (not directories)"
    )

    parser.add_argument(
        "-n", "--dry-run",
        action="store_true",
        help="Show what would happen without making changes"
    )

    args = parser.parse_args()

    create_symlinks(args.config, args.force, args.dry_run)


if __name__ == "__main__":
    main()
