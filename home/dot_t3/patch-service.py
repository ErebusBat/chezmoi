#!/usr/bin/env python3
"""Restore T3's bind environment after its installer replaces the user unit."""

import os
from pathlib import Path
import shlex
import subprocess


def main():
    config = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    unit = config / "systemd/user/t3code.service"
    original = unit.read_text()
    lines = original.splitlines(keepends=True)
    desired = {"T3CODE_HOST": "::", "T3CODE_PORT": "3773"}
    environment = {}
    in_service = False
    insert_at = None

    for index, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            in_service = stripped == "[Service]"
        if not in_service:
            continue
        insert_at = index + 1
        key, separator, value = stripped.partition("=")
        if separator and key.strip() == "Environment":
            assignments = shlex.split(value, comments=False)
            if not assignments:
                environment.clear()
            for assignment in assignments:
                name, equals, setting = assignment.partition("=")
                if equals:
                    environment[name] = setting

    if insert_at is None:
        raise SystemExit(f"No [Service] section in {unit}; refusing to patch")

    missing = {key: value for key, value in desired.items()
               if environment.get(key) != value}
    if not missing:
        print(f"{unit}: bind settings already correct; no restart needed")
        return

    # Later Environment assignments override earlier values, preserving all
    # installer-owned directives and unrelated environment variables.
    addition = "".join(f"Environment={key}={value}\n" for key, value in missing.items())
    if not lines[insert_at - 1].endswith("\n"):
        addition = "\n" + addition
    lines.insert(insert_at, addition)
    unit.write_text("".join(lines))
    print(f"Patched {unit}", flush=True)
    subprocess.run(["systemctl", "--user", "daemon-reload"], check=True)
    subprocess.run(["systemctl", "--user", "restart", "t3code.service"], check=True)


if __name__ == "__main__":
    main()
