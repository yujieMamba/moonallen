#!/usr/bin/env python3
"""Reproducible production LOC and history inventory; not a correctness verdict."""
import argparse
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXCLUDED = {".git", "_build", "target", ".mooncakes", "examples", "benchmarks", "vendor", "generated"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=pathlib.Path)
    args = parser.parse_args()
    production = []
    tests = []
    for path in sorted(ROOT.rglob("*.mbt")):
        rel = path.relative_to(ROOT)
        if any(part in EXCLUDED for part in rel.parts):
            continue
        rows = path.read_text(encoding="utf-8-sig").splitlines()
        entry = {"path": rel.as_posix(), "physical_lines": len(rows),
                 "nonblank_lines": sum(bool(row.strip()) for row in rows)}
        if path.name.endswith(("_test.mbt", "_wbtest.mbt")):
            tests.append(entry)
        else:
            production.append(entry)
    assert production, "no production MoonBit files"
    total = sum(item["physical_lines"] for item in production)
    assert total >= 1500, f"production threshold not met: {total}"
    result = {"module": "yujieMamba/moonallen", "version": "0.1.0",
              "production_physical_lines": total,
              "production_nonblank_lines": sum(item["nonblank_lines"] for item in production),
              "production_files": production, "test_files": tests,
              "exclusions": sorted(EXCLUDED),
              "history_note": "Total commits are not automatically meaningful commits; manual audit required."}
    if (ROOT / ".git").exists():
        raw = subprocess.check_output(
            ["git", "log", "--reverse", "--format=%H%x09%s"], cwd=ROOT, text=True, encoding="utf-8")
        result["commits"] = [dict(zip(("sha", "purpose"), line.split("\t", 1)))
                             for line in raw.splitlines()]
        result["total_commits"] = len(result["commits"])
    text = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(text, encoding="utf-8")
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
