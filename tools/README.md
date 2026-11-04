# Export tools

These scripts generated this repo from the binary place file. Re-run them after big changes made in Studio (new scripts, moved folders) to bring the repo back in sync. For day-to-day edits, Rojo is simpler.

Requires Python 3.10+. From the repo root in PowerShell:

```powershell
pip install -r tools/requirements.txt

# 1. Parse the place (binary .rbxl) into an instance tree
python tools/parse_rbxl.py "C:\path\to\place.rbxl" tree.json

# 2. Regenerate src/ (delete it first so removed scripts don't linger)
Remove-Item -Recurse -Force src
python tools/build_project.py tree.json . eat-to-be-powerful

Remove-Item tree.json, tree.json.report.json
```

`build_project.py` prints:

- every instance it had to rename to get a valid Windows filename;
- disabled scripts and non-default `RunContext` values (these are written to `*.meta.json`);
- duplicate UI template clones that were collapsed into one.

What the parser reads: `Name`, `Source`, `Disabled` and `RunContext` on every instance, plus the parent/child tree. Everything else in the place (parts, UI properties, terrain) is ignored. It handles both zstd- and LZ4-compressed chunks.

Check the result with:

```powershell
rojo build default.project.json -o check.rbxlx
```
