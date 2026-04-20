#!/usr/bin/env python3
"""pocket-wiki setup — installs Graphify, registers the skill, creates folders.

Cross-platform (replaces setup.sh / setup.ps1). Run with:
    python setup.py
or:
    python3 setup.py
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path


SKILL_ENTRY = (
    "# pocket-wiki\n"
    "- **pocket-wiki** (`~/.claude/skills/pocket-wiki/SKILL.md`) - "
    "personal knowledge base. Trigger: `/pocket-wiki`\n"
)


def step(n: int, total: int, msg: str) -> None:
    print(f"[{n}/{total}] {msg}")


def run(cmd: list[str], *, fatal: bool = True) -> int:
    """Run a subprocess, optionally exiting on failure."""
    result = subprocess.run(cmd, check=False)
    if fatal and result.returncode != 0:
        print(f"ERROR: {' '.join(cmd)} failed with exit {result.returncode}")
        sys.exit(1)
    return result.returncode


def install_graphify() -> None:
    step(1, 4, "Installing Graphify...")
    run([sys.executable, "-m", "pip", "install", "graphifyy", "-q"])


def register_skill(repo_root: Path, home: Path) -> None:
    step(2, 4, "Registering Claude Code skill...")

    # Configure graphify for Claude Code
    run([sys.executable, "-m", "graphify", "install", "--platform", "claude"], fatal=False)

    skill_dir = home / ".claude" / "skills" / "pocket-wiki"
    skill_dir.mkdir(parents=True, exist_ok=True)

    skill_src = repo_root / "SKILL.md"
    if not skill_src.exists():
        print(f"ERROR: SKILL.md not found at {skill_src}")
        sys.exit(1)
    shutil.copy2(skill_src, skill_dir / "SKILL.md")

    config = {"pocketRoot": str(repo_root).replace("\\", "/")}
    (skill_dir / "config.json").write_text(
        json.dumps(config) + "\n", encoding="utf-8"
    )
    print(f"  pocketRoot: {repo_root}")

    claude_md = home / ".claude" / "CLAUDE.md"
    existing = claude_md.read_text(encoding="utf-8") if claude_md.exists() else ""
    if "pocket-wiki" in existing:
        print("  pocket-wiki skill already registered.")
        return

    claude_md.parent.mkdir(parents=True, exist_ok=True)
    prefix = "" if not existing or existing.endswith("\n") else "\n"
    with claude_md.open("a", encoding="utf-8") as f:
        f.write(prefix + "\n" + SKILL_ENTRY)
    print("  pocket-wiki skill registered.")


def create_folders(repo_root: Path) -> None:
    step(3, 4, "Creating folder structure...")
    folders = [
        "raw/files",
        "raw/crawled",
        "graphify-out",
        "LLM Wiki/graph",
        "LLM Wiki/wiki/sources",
        "LLM Wiki/_meta",
    ]
    for f in folders:
        (repo_root / f).mkdir(parents=True, exist_ok=True)
    print("  Folders created.")


def print_next_steps(repo_root: Path) -> None:
    step(4, 4, "Done!\n")
    print("Next steps:")
    print("  1. Open 'LLM Wiki/' as your Obsidian vault")
    print("  2. Install 'Local REST API' community plugin and enable it")
    print("  3. Run Claude Code from this directory:")
    print(f"       cd {repo_root}")
    print("       claude")
    print()
    print("Add a source:    /pocket-wiki <url or title>")
    print("Query the wiki:  /pocket-wiki query <question>")


def main() -> None:
    repo_root = Path(__file__).parent.resolve()
    home = Path.home()
    print("Setting up pocket-wiki...\n")
    install_graphify()
    register_skill(repo_root, home)
    create_folders(repo_root)
    print_next_steps(repo_root)


if __name__ == "__main__":
    main()
