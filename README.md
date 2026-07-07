# Mohavise Pi-hole Adlist

This repository is the Pi-hole child/output repo of the main Mohavise adblock core project.

It builds a Pi-hole-ready adlist from the shared core domain list.
Source lists, upstream changes, custom blocks, allowlists, and data validation are managed in the parent core repo:

```text
https://github.com/mohavise/mohavise-adblock-core
```

## Relationship

```text
mohavise-adblock-core
        ↓
mohavise-pihole-adlist
        ↓
Pi-hole Gravity
```

## Daily Timing

GitHub Actions runs at `00:00 UTC`, which is `03:30 Asia/Tehran`.

## Materials / Output Files

This repo has one final Pi-hole material:

| File | Format | Main Use |
| --- | --- | --- |
| `pihole-adlist.txt` | Plain domain list, one domain per line | Main file used by Pi-hole Adlists / Gravity |

The parent repo is responsible for cleaning and validating the data before this repo builds the Pi-hole output.

## Use In Pi-hole

Add this URL to Pi-hole Adlists:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adlist.txt
```

Then update gravity from the Pi-hole web UI, or run:

```bash
pihole -g
```

## Files

| File | Purpose |
| --- | --- |
| `pihole-adlist.txt` | Final generated Pi-hole domain list |
| `scripts/build-pihole-adlist.sh` | Downloads the core list and builds the final Pi-hole file |

## Build

```bash
./scripts/build-pihole-adlist.sh
```

## Marker

Generated files use this marker:

```text
managed-by=mohavise-pihole-adlist
```

## Logic

```text
mohavise-adblock-core/core-domains.txt = validated canonical source
mohavise-pihole-adlist/pihole-adlist.txt = Pi-hole-ready output
```
