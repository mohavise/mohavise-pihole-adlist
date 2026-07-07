# Cleanup Policy

This repository is part of the Mohavise adblock pipeline. Do not delete files only because they look duplicated, old, large, or generated.

## Safe cleanup rule

A file can be removed only when all of these are true:

```text
not used by a GitHub Actions workflow
not used by a build script
not documented as an output
not used by a device-side process
not used as a raw URL endpoint
not kept for compatibility or fallback
not needed for future scheduled generation
```

If any item is false or unknown, keep the file.

## Required review before deletion

Before deleting any file:

1. Check `.github/workflows/` for `git add`, script calls, and output references.
2. Check `scripts/` for input and output variables.
3. Check `README.md` for documented public URLs and compatibility notes.
4. Check Pi-hole usage notes and raw URL endpoints.
5. Prepare a removal report with risk level.
6. Delete only after explicit approval.

## Current intentional files

These files are intentional and must not be removed without a full process change:

```text
pihole-adblock-adlist.txt
pihole-adult-adlist.txt
pihole-adlist.txt
scripts/build-pihole-adlist.sh
.github/workflows/update-pihole-adlist.yml
```

## Notes

`pihole-adlist.txt` is the combined compatibility output. The category outputs are kept for separate Pi-hole management and future expansion.
