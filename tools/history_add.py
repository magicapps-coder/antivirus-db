#!/usr/bin/env python3
"""Adds one row to HISTORY.md (newest first). HISTORY_DATE overrides the date (backfill).
Usage: history_add.py <kind: signatures|links> <version> <release tag> <entries text> [generated_at]"""
import datetime, os, sys
kind, version, tag, entries = sys.argv[1:5]
gen = sys.argv[5] if len(sys.argv) > 5 else ""
repo = os.environ.get("GITHUB_REPOSITORY", "magicapps-coder/antivirus-db")
path = "HISTORY.md"
head = ("# History\n\n"
        "Every published database, newest first. The app always uses the newest one:\n"
        "signatures from `releases/latest`, links from `links/` on `main`. Older versions stay downloadable here.\n\n"
        "| Date (UTC) | Database | Version | Entries | Data generated | Download |\n"
        "|---|---|---|---|---|---|\n")
rows = []
if os.path.exists(path):
    lines = open(path, encoding="utf-8").read().splitlines()
    rows = [l for l in lines if l.startswith("| 20")]
now = os.environ.get("HISTORY_DATE") or datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M")
row = f"| {now} | {kind} | `{version}` | {entries} | {gen} | [{tag}](https://github.com/{repo}/releases/tag/{tag}) |"
if not any(f"/releases/tag/{tag})" in r for r in rows):
    rows.insert(0, row)
open(path, "w", encoding="utf-8").write(head + "\n".join(rows) + "\n")
print(row)
