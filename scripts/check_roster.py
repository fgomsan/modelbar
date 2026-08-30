#!/usr/bin/env python3
"""Validate Grok Bot kit layout. Stdlib only."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_PROFILE_HEADINGS = ("# ", "## Description")
REQUIRED_SKILL_SECTIONS = (
    "## When to use it",
    "## Required inputs and access",
    "## Sequence of work",
    "## How to validate",
    "## What to return",
    "## What requires approval",
)
FRONTMATTER_NAME = re.compile(r"^name:\s*\S+", re.M)
FRONTMATTER_DESC = re.compile(r"^description:", re.M)


def fail(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(1)


def parse_frontmatter(text: str, path: Path) -> str:
    if not text.startswith("---"):
        fail(f"{path}: missing YAML frontmatter")
    end = text.find("\n---", 3)
    if end == -1:
        fail(f"{path}: unclosed frontmatter")
    fm = text[3:end]
    if not FRONTMATTER_NAME.search(fm):
        fail(f"{path}: frontmatter needs name:")
    if not FRONTMATTER_DESC.search(fm):
        fail(f"{path}: frontmatter needs description:")
    return fm


def check_bots() -> list[str]:
    names: list[str] = []
    bots = ROOT / "bots"
    if not bots.is_dir():
        fail("bots/ missing")
    for folder in sorted(p for p in bots.iterdir() if p.is_dir()):
        profile = folder / "PROFILE.md"
        first = folder / "FIRST_TASK.md"
        if not profile.is_file():
            fail(f"{profile} missing")
        if not first.is_file():
            fail(f"{first} missing")
        body = profile.read_text(encoding="utf-8")
        for heading in REQUIRED_PROFILE_HEADINGS:
            if heading not in body:
                fail(f"{profile}: missing {heading!r}")
        if "**Name**" not in body or "**Title**" not in body:
            fail(f"{profile}: need Name and Title fields")
        names.append(folder.name)
    if len(names) < 1:
        fail("no bots")
    return names


def check_skills() -> list[str]:
    names: list[str] = []
    skills = ROOT / ".grok" / "skills"
    if not skills.is_dir():
        fail(".grok/skills/ missing")
    for folder in sorted(p for p in skills.iterdir() if p.is_dir()):
        skill = folder / "SKILL.md"
        if not skill.is_file():
            fail(f"{skill} missing")
        text = skill.read_text(encoding="utf-8")
        parse_frontmatter(text, skill)
        for section in REQUIRED_SKILL_SECTIONS:
            if section not in text:
                fail(f"{skill}: missing {section}")
        if folder.name != folder.name.lower() or " " in folder.name:
            fail(f"{folder}: use kebab-case directory names")
        names.append(folder.name)
    return names


def check_routines() -> None:
    routines = ROOT / "routines"
    if not routines.is_dir():
        fail("routines/ missing")
    files = list(routines.glob("*.md"))
    if not files:
        fail("no routines")
    for path in files:
        text = path.read_text(encoding="utf-8")
        if "Owning Bot" not in text and "Owner Bot" not in text:
            fail(f"{path}: name the owning Bot")


def main() -> None:
    bots = check_bots()
    skills = check_skills()
    check_routines()
    for required in ("README.md", "AGENTS.md", "LICENSE"):
        if not (ROOT / required).is_file():
            fail(f"{required} missing")
    print(f"ok: {len(bots)} bots, {len(skills)} skills")


if __name__ == "__main__":
    main()
