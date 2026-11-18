#!/usr/bin/env python3

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path


def backup_path(destination):
    """Return a non-existing backup path next to destination."""
    candidate = destination.with_name(destination.name + ".bak")
    if not candidate.exists() and not candidate.is_symlink():
        return candidate

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    candidate = destination.with_name(f"{destination.name}.bak.{stamp}")
    counter = 1
    while candidate.exists() or candidate.is_symlink():
        candidate = destination.with_name(
            f"{destination.name}.bak.{stamp}-{counter}"
        )
        counter += 1
    return candidate


def load_links(config_file):
    try:
        with config_file.open("r", encoding="utf-8") as f:
            links = json.load(f)
    except FileNotFoundError:
        print(f"error: links file not found: {config_file}", file=sys.stderr)
        return None
    except json.JSONDecodeError as error:
        print(
            f"error: invalid JSON in {config_file}: {error}",
            file=sys.stderr,
        )
        return None
    except OSError as error:
        print(f"error: cannot read {config_file}: {error}", file=sys.stderr)
        return None

    if not isinstance(links, dict):
        print(
            f"error: invalid links file {config_file}: "
            "top-level value must be an object",
            file=sys.stderr,
        )
        return None

    for source, destination in links.items():
        if not isinstance(source, str) or not source:
            print(
                f"error: invalid links file {config_file}: "
                "source paths must be non-empty strings",
                file=sys.stderr,
            )
            return None
        if not isinstance(destination, str) or not destination:
            print(
                f"error: invalid links file {config_file}: "
                f"destination for {source!r} must be a non-empty string",
                file=sys.stderr,
            )
            return None

    return links


def create_symlinks(config_file, force=False, backup=False, dry_run=False):
    config_file = Path(config_file).resolve()
    repo_dir = config_file.parent

    links = load_links(config_file)
    if links is None:
        return 2

    linked = 0
    already_ok = 0
    skipped = 0
    failed = 0

    for source, destination in links.items():
        src = (repo_dir / source).resolve()
        dst = Path(os.path.expandvars(os.path.expanduser(destination)))

        if not src.exists():
            print(f"[FAIL] Source does not exist: {src}")
            failed += 1
            continue

        if dst.is_symlink() and dst.resolve() == src:
            print(f"[OK]   Already linked: {dst}")
            already_ok += 1
            continue

        if dst.exists() or dst.is_symlink():
            if backup:
                saved = backup_path(dst)
                if dry_run:
                    print(f"[DRY]  Would back up: {dst} -> {saved}")
                else:
                    try:
                        dst.rename(saved)
                    except OSError as error:
                        print(f"[FAIL] Could not back up {dst}: {error}")
                        failed += 1
                        continue
                    print(f"[BACKUP] {dst} -> {saved}")
            elif not force:
                print(f"[SKIP] Destination exists: {dst}")
                skipped += 1
                continue
            elif dst.is_dir() and not dst.is_symlink():
                print(f"[SKIP] Refusing to replace directory: {dst}")
                skipped += 1
                continue
            elif dry_run:
                print(f"[DRY]  Would remove: {dst}")
            else:
                try:
                    dst.unlink()
                except OSError as error:
                    print(f"[FAIL] Could not remove {dst}: {error}")
                    failed += 1
                    continue

        if dry_run:
            print(f"[DRY]  Would link: {dst} -> {src}")
            linked += 1
            continue

        try:
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.symlink_to(src, target_is_directory=src.is_dir())
        except OSError as error:
            print(f"[FAIL] Could not link {dst} -> {src}: {error}")
            failed += 1
            continue

        print(f"[LINK] {dst} -> {src}")
        linked += 1

    print(
        f"Summary: linked={linked}, already_ok={already_ok}, "
        f"skipped={skipped}, failed={failed}"
    )
    return 1 if failed else 0


def main():
    parser = argparse.ArgumentParser(
        description="Create symlinks for dotfiles."
    )

    parser.add_argument(
        "-c", "--config",
        type=Path,
        default=Path(__file__).resolve().with_name("links.json"),
        help="Path to links.json (defaults to the file next to this script)"
    )

    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Replace existing files or symlinks (not directories)"
    )

    parser.add_argument(
        "-b", "--backup",
        action="store_true",
        help="Rename existing destinations to <name>.bak before linking"
    )

    parser.add_argument(
        "-n", "--dry-run",
        action="store_true",
        help="Show what would happen without making changes"
    )

    args = parser.parse_args()

    return create_symlinks(
        args.config,
        force=args.force,
        backup=args.backup,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    sys.exit(main())
