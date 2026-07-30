#!/usr/bin/env python3
"""Normalize Chromium patch paths and timestamps.

The generated Chromium LoongArch patchset is produced from two source trees
(`a` and `b`).  Every patch header must be deterministic:

  --- a/path\t2000-01-01 00:00:00.000000000 +0800
  +++ b/path\t2000-01-01 00:00:00.000000000 +0800
"""

from __future__ import annotations

import re
import shlex
import shutil
import sys
import tempfile
from pathlib import PurePosixPath

TIMESTAMP = "2000-01-01 00:00:00.000000000 +0800"
DIFF_PREFIX = (
    "diff '--color=auto' -p -X ../chromium-loongarch64/chromium/exclude "
    "-N -u -r"
)

_FILE_LINE_RE = re.compile(r"^(---|\+\+\+)\s+(\S+)(?:\s+.*)?$")


def _relative_path(path: str) -> str:
    """Return a path relative to the clean/patched tree root."""
    if path == "/dev/null":
        return path

    posix = PurePosixPath(path.replace("\\", "/"))
    parts = posix.parts

    # Absolute paths may look like /mnt/.../a/foo or /mnt/.../b/foo.
    for marker in ("a", "b"):
        if marker in parts:
            index = parts.index(marker)
            if index + 1 < len(parts):
                return "/".join(parts[index + 1 :])

    # Normal diff output from `diff ... a b` is a/foo or b/foo.
    if parts and parts[0] in ("a", "b"):
        return "/".join(parts[1:])

    return str(posix)


def normalize_diff_lines(lines: list[str]) -> list[str]:
    """Normalize diff command lines plus ---/+++ headers."""
    normalized: list[str] = []

    for line in lines:
        if line.startswith("diff "):
            tokens = shlex.split(line)
            if len(tokens) < 3:
                raise ValueError(f"malformed diff line: {line.rstrip()}")
            old_rel = _relative_path(tokens[-2])
            new_rel = _relative_path(tokens[-1])
            rel = new_rel if old_rel == "/dev/null" else old_rel
            normalized.append(f"{DIFF_PREFIX} a/{rel} b/{rel}\n")
            continue

        file_match = _FILE_LINE_RE.match(line)
        if file_match:
            marker, path = file_match.groups()
            if path == "/dev/null":
                normalized.append(f"{marker} /dev/null\t{TIMESTAMP}\n")
                continue
            rel = _relative_path(path)
            tree = "a" if marker == "---" else "b"
            normalized.append(f"{marker} {tree}/{rel}\t{TIMESTAMP}\n")
            continue

        normalized.append(line)

    return normalized


def normalize_diff_file(input_file: str, output_file: str) -> None:
    with open(input_file, "r", encoding="utf-8") as f_in:
        lines = f_in.readlines()

    with open(output_file, "w", encoding="utf-8") as f_out:
        f_out.writelines(normalize_diff_lines(lines))


def main() -> None:
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print(f"Usage: {sys.argv[0]} <diff_file> [output_file]")
        print(f"Example: {sys.argv[0]} input.diff           # in-place")
        print(f"         {sys.argv[0]} input.diff output.diff")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) == 3 else None

    try:
        if output_file is None:
            with tempfile.NamedTemporaryFile(mode="w", delete=False, encoding="utf-8") as tmp_file:
                tmp_path = tmp_file.name
            normalize_diff_file(input_file, tmp_path)
            shutil.move(tmp_path, input_file)
            print(f"Successfully formatted diff file: {input_file}")
        else:
            normalize_diff_file(input_file, output_file)
            print(f"Successfully formatted diff file: {input_file} -> {output_file}")
    except Exception as exc:
        print(f"Error formatting diff file: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
