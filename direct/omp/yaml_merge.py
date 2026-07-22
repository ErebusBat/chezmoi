#!/usr/bin/env python3
"""Merge a primary YAML mapping into a secondary YAML mapping in place."""

from __future__ import annotations

import argparse
import os
import sys
import tempfile
from collections.abc import Mapping
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    print(
        "PyYAML is required; install it with: python3 -m pip install --user PyYAML",
        file=sys.stderr,
    )
    raise SystemExit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Merge PRIMARY YAML fields into SECONDARY YAML in place."
    )
    parser.add_argument("primary", type=Path, metavar="PRIMARY")
    parser.add_argument("secondary", type=Path, metavar="SECONDARY")
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        metavar="PATH",
        help="Preserve an exact dotted mapping path from SECONDARY.",
    )
    parser.add_argument(
        "--strict-excludes",
        action="store_true",
        help="Fail if an excluded path is unresolved in either input.",
    )
    return parser.parse_args()


def parse_exclusions(paths: list[str]) -> list[tuple[str, ...]]:
    exclusions: list[tuple[str, ...]] = []
    for path in paths:
        segments = tuple(path.split("."))
        if not path or any(not segment for segment in segments):
            raise ValueError(f"invalid excluded path: {path!r}")
        exclusions.append(segments)
    return exclusions


def load_mapping(path: Path, *, missing_is_empty: bool) -> dict[Any, Any]:
    try:
        with path.open(encoding="utf-8") as source:
            documents = list(yaml.safe_load_all(source))
    except FileNotFoundError:
        if missing_is_empty:
            return {}
        raise ValueError(f"cannot read {path}: file does not exist") from None
    except (OSError, yaml.YAMLError) as error:
        raise ValueError(f"cannot read YAML from {path}: {error}") from error

    if not documents and missing_is_empty:
        return {}
    if len(documents) != 1:
        raise ValueError(f"{path} must contain exactly one YAML document")

    document = documents[0]
    if document is None and missing_is_empty:
        return {}
    if not isinstance(document, Mapping):
        raise ValueError(f"{path} must contain a YAML mapping at its root")
    return dict(document)


def path_is_resolved(mapping: Mapping[Any, Any], path: tuple[str, ...]) -> bool:
    current: Any = mapping
    for segment in path:
        if not isinstance(current, Mapping) or segment not in current:
            return False
        current = current[segment]
    return True


def merge_mappings(
    primary: Mapping[Any, Any],
    secondary: Mapping[Any, Any],
    exclusions: list[tuple[str, ...]],
) -> dict[Any, Any]:
    """Merge mappings without mutating either input."""
    result = dict(secondary)
    if not exclusions:
        result.update(primary)
        return result

    for key, primary_value in primary.items():
        descendants = [path[1:] for path in exclusions if path[0] == key]
        if not descendants:
            result[key] = primary_value
            continue

        if () in descendants:
            continue

        secondary_value = secondary[key]
        result[key] = merge_mappings(primary_value, secondary_value, descendants)

    return result


def write_atomically(path: Path, mapping: Mapping[Any, Any]) -> None:
    temporary_name: str | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", dir=path.parent, delete=False
        ) as temporary:
            temporary_name = temporary.name
            yaml.safe_dump(mapping, temporary, default_flow_style=False, sort_keys=False)
            temporary.flush()
            os.fsync(temporary.fileno())
        os.replace(temporary_name, path)
    except (OSError, yaml.YAMLError) as error:
        if temporary_name is not None:
            try:
                os.unlink(temporary_name)
            except FileNotFoundError:
                pass
        raise ValueError(f"cannot replace {path}: {error}") from error


def main() -> int:
    args = parse_args()
    try:
        exclusions = parse_exclusions(args.exclude)
        primary = load_mapping(args.primary, missing_is_empty=False)
        secondary = load_mapping(args.secondary, missing_is_empty=True)
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    active_exclusions: list[tuple[str, ...]] = []
    unresolved: list[str] = []
    for exclusion in exclusions:
        if path_is_resolved(primary, exclusion) and path_is_resolved(secondary, exclusion):
            active_exclusions.append(exclusion)
        else:
            unresolved.append(".".join(exclusion))

    if unresolved:
        for path in unresolved:
            print(f"warning: excluded path {path} is unresolved", file=sys.stderr)
        if args.strict_excludes:
            return 1

    merged = merge_mappings(primary, secondary, active_exclusions)
    try:
        write_atomically(args.secondary, merged)
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
