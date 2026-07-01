# Mohavise Pi-hole Adlist

This project builds a clean Pi-hole adlist every day from upstream block sources.

The first source is HaGeZi `light.txt`, a conservative starting point. After testing, you can change `config/sources.txt` to HaGeZi `multi.txt` or `pro.txt` for stronger blocking.

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
| `config/sources.txt` | Upstream blocklist URLs |
| `config/allowlist-core.txt` | Domains that must not be blocked |
| `config/blocklist-custom.txt` | Your own blocked domains |
| `scripts/build-pihole-adlist.ps1` | Builds the final Pi-hole files |

## Marker

Generated files use this marker:

```text
managed-by=mohavise-pihole-adlist
```

## Logic

```text
upstream sources + custom blocklist - allowlist = final Pi-hole adlist
```

