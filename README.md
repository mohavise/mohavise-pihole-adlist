# Mohavise Pi-hole Adlist

This project builds Pi-hole outputs from the shared Mohavise adblock core list.

Source and allowlist changes are managed in the core repo:

```text
https://github.com/mohavise/mohavise-adblock-core
```

## Daily Timing

GitHub Actions runs at `23:30 UTC`, which is `03:00 Asia/Tehran`.

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
| `pihole-hosts.txt` | Optional hosts-format output |
| `scripts/build-pihole-adlist.ps1` | Downloads the core list and builds the final Pi-hole files |

## Marker

Generated files use this marker:

```text
managed-by=mohavise-pihole-adlist
```

## Logic

```text
upstream sources + custom blocklist - allowlist = final Pi-hole adlist
```
