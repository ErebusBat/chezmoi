from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

import yaml


SCRIPT = Path(__file__).with_name("yaml_merge.py")


class YamlMergeCliTest(unittest.TestCase):
    def run_merge(self, primary: Path, secondary: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(primary), str(secondary), *arguments],
            capture_output=True,
            text=True,
            check=False,
        )

    def write_yaml(self, path: Path, contents: object) -> None:
        path.write_text(yaml.safe_dump(contents, sort_keys=False), encoding="utf-8")

    def test_selective_mapping_merge_preserves_excluded_leaf(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            primary = temporary / "primary.yml"
            secondary = temporary / "secondary.yml"
            self.write_yaml(
                primary,
                {
                    "database": {"host": "primary-host", "user": "primary-user"},
                    "items": ["primary", "sequence"],
                    "primary_only": True,
                },
            )
            self.write_yaml(
                secondary,
                {
                    "database": {"host": "secondary-host", "user": "secondary-user", "port": 5432},
                    "items": ["secondary"],
                    "secondary_only": True,
                },
            )

            completed = self.run_merge(primary, secondary, "--exclude", "database.host")

            self.assertEqual(completed.returncode, 0, completed.stderr)
            with secondary.open(encoding="utf-8") as result_file:
                result = yaml.safe_load(result_file)
            self.assertEqual(
                result,
                {
                    "database": {"host": "secondary-host", "user": "primary-user", "port": 5432},
                    "items": ["primary", "sequence"],
                    "secondary_only": True,
                    "primary_only": True,
                },
            )

    def test_blank_and_missing_secondary_become_primary_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            primary = temporary / "primary.yml"
            self.write_yaml(primary, {"nested": {"value": 1}, "items": ["one"]})

            for name in ("blank.yml", "missing.yml"):
                with self.subTest(secondary=name):
                    secondary = temporary / name
                    if name == "blank.yml":
                        secondary.write_text("", encoding="utf-8")

                    completed = self.run_merge(primary, secondary)

                    self.assertEqual(completed.returncode, 0, completed.stderr)
                    with secondary.open(encoding="utf-8") as result_file:
                        self.assertEqual(yaml.safe_load(result_file), {"nested": {"value": 1}, "items": ["one"]})

    def test_missing_exclusion_warns_and_uses_normal_precedence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            primary = temporary / "primary.yml"
            secondary = temporary / "secondary.yml"
            self.write_yaml(primary, {"conflict": "primary"})
            self.write_yaml(secondary, {"conflict": "secondary"})

            completed = self.run_merge(primary, secondary, "--exclude", "missing.path")

            self.assertEqual(completed.returncode, 0, completed.stderr)
            self.assertEqual(completed.stderr, "warning: excluded path missing.path is unresolved\n")
            with secondary.open(encoding="utf-8") as result_file:
                self.assertEqual(yaml.safe_load(result_file), {"conflict": "primary"})

    def test_strict_missing_exclusion_preserves_secondary_bytes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            primary = temporary / "primary.yml"
            secondary = temporary / "secondary.yml"
            self.write_yaml(primary, {"conflict": "primary"})
            secondary.write_bytes(b"conflict: secondary\n# retained if strict mode fails\n")
            original = secondary.read_bytes()

            completed = self.run_merge(
                primary, secondary, "--exclude", "missing.path", "--strict-excludes"
            )

            self.assertNotEqual(completed.returncode, 0)
            self.assertEqual(completed.stderr, "warning: excluded path missing.path is unresolved\n")
            self.assertEqual(secondary.read_bytes(), original)

    def test_invalid_primary_does_not_replace_secondary(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            secondary = temporary / "secondary.yml"
            secondary.write_bytes(b"keep: this exact content\n")
            original = secondary.read_bytes()

            for contents in ("---\nfirst: document\n---\nsecond: document\n", "- not\n- a mapping\n"):
                with self.subTest(primary=contents):
                    primary = temporary / "primary.yml"
                    primary.write_text(contents, encoding="utf-8")

                    completed = self.run_merge(primary, secondary)

                    self.assertNotEqual(completed.returncode, 0)
                    self.assertEqual(secondary.read_bytes(), original)


if __name__ == "__main__":
    unittest.main()
