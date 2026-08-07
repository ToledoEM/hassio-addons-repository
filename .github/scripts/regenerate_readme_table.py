#!/usr/bin/env python3
"""Rebuild the '## Add-ons' table in README.md from each addon's config.yaml."""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
ADDONS_TXT = REPO_ROOT / "addons.txt"
README = REPO_ROOT / "README.md"

TABLE_HEADER = "| Icon | Name | Slug | Version | Description |\n| :--- | :--- | :--- | :--- | :--- |\n"


def addon_row(slug: str) -> str:
    config = yaml.safe_load((REPO_ROOT / slug / "config.yaml").read_text())
    name = config["name"]
    version = config["version"]
    description = config["description"]
    return (
        f'| <img src="{slug}/icon.png" width="150" height="150" /> '
        f"| [{name}]({slug}/README.md) | {slug} | {version} | {description} |\n"
    )


def main() -> int:
    slugs = [
        line.strip()
        for line in ADDONS_TXT.read_text().splitlines()
        if line.strip()
    ]
    rows = "".join(addon_row(slug) for slug in slugs)

    content = README.read_text()
    pattern = re.compile(
        r"(## Add-ons\n)"
        r"\| Icon \| Name \| Slug \| Version \| Description \|\n"
        r"\| :--- \| :--- \| :--- \| :--- \| :--- \|\n"
        r"(?:\|.*\|\n)*"
    )
    if not pattern.search(content):
        print("could not find Add-ons table in README.md", file=sys.stderr)
        return 1

    new_content = pattern.sub(r"\1" + TABLE_HEADER + rows, content)
    README.write_text(new_content)
    return 0


if __name__ == "__main__":
    sys.exit(main())
