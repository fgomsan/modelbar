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
    for folder in sorted(
        p for p in bots.iterdir() if p.is_dir() and not p.name.startswith("_")
    ):
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


def check_routines() -> list[str]:
    routines = ROOT / "routines"
    if not routines.is_dir():
        fail("routines/ missing")
    files = sorted(routines.glob("*.md"))
    if not files:
        fail("no routines")
    names: list[str] = []
    for path in files:
        text = path.read_text(encoding="utf-8")
        if "Owning Bot" not in text and "Owner Bot" not in text:
            fail(f"{path}: name the owning Bot")
        names.append(path.name)
    return names


def check_version() -> str:
    path = ROOT / "VERSION"
    if not path.is_file():
        fail("VERSION missing")
    version = path.read_text(encoding="utf-8").strip()
    if not re.match(r"^\d+\.\d+\.\d+$", version):
        fail("VERSION must be semver X.Y.Z")
    return version


def check_groups() -> list[str]:
    groups = ROOT / "groups"
    if not groups.is_dir():
        fail("groups/ missing")
    files = sorted(p for p in groups.glob("*.md") if p.is_file())
    if not files:
        fail("no groups")
    return [p.name for p in files]


def check_extract_docs() -> None:
    for name in ("EXTRACT.md", "CONNECTORS.md", "CHANGELOG.md"):
        if not (ROOT / name).is_file():
            fail(f"{name} missing")
    extract = (ROOT / "EXTRACT.md").read_text(encoding="utf-8")
    if "fgomsan/grok-bots" not in extract:
        fail("EXTRACT.md: name the destination repo")
    if "publish.sh" not in extract:
        fail("EXTRACT.md: document publish.sh")
    if "grok-bots-v" not in extract:
        fail("EXTRACT.md: document grok-bots-v version tag")
    if "package.sh" not in extract:
        fail("EXTRACT.md: document package.sh")
    connectors = (ROOT / "CONNECTORS.md").read_text(encoding="utf-8")
    if "Settings → Plugins" not in connectors:
        fail("CONNECTORS.md: document Settings → Plugins")


def check_readme(
    bots: list[str],
    skills: list[str],
    routines: list[str],
    groups: list[str],
) -> None:
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    for name in bots:
        if f"bots/{name}" not in readme:
            fail(f"README.md: missing bots/{name}")
    for name in skills:
        if name not in readme:
            fail(f"README.md: missing skill {name}")
    for name in routines:
        if name not in readme:
            fail(f"README.md: missing routine {name}")
    for name in groups:
        if f"groups/{name}" not in readme and name not in readme:
            fail(f"README.md: missing group {name}")
    for token in ("EXTRACT.md", "CONNECTORS.md", "VERSION"):
        if token not in readme:
            fail(f"README.md: missing {token}")


def main() -> None:
    bots = check_bots()
    skills = check_skills()
    routines = check_routines()
    groups = check_groups()
    version = check_version()
    check_extract_docs()
    for required in ("README.md", "AGENTS.md", "LICENSE", "SHARE.md"):
        if not (ROOT / required).is_file():
            fail(f"{required} missing")
    publish = ROOT / "scripts" / "publish.sh"
    if not publish.is_file():
        fail("scripts/publish.sh missing")
    package = ROOT / "scripts" / "package.sh"
    if not package.is_file():
        fail("scripts/package.sh missing")
    release_wf = ROOT / ".github" / "workflows" / "release-kit.yml"
    if not release_wf.is_file():
        fail(".github/workflows/release-kit.yml missing")
    check_readme(bots, skills, routines, groups)
    print(
        f"ok: v{version} {len(bots)} bots, {len(skills)} skills, "
        f"{len(routines)} routines, {len(groups)} groups"
    )


if __name__ == "__main__":
    main()
