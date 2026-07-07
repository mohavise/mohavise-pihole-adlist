# Mohavise Pi-hole Adlist

This repository is the Pi-hole child/output repo of the main Mohavise adblock core project.

It builds Pi-hole-ready adlist outputs from the validated parent core lists.
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

Pi-hole updates whenever you run Gravity manually or through your own Pi-hole schedule.

## Output Strategy

This repo now supports separate endpoint lists.

```text
adblock list = ads / trackers
adult list   = adult / NSFW domains
combined     = adblock + adult together
```

For normal production use, add both separate URLs to Pi-hole:

```text
pihole-adblock-adlist.txt
pihole-adult-adlist.txt
```

This lets Pi-hole show and manage the two categories separately.

## Materials / Output Files

| File | Format | Main Use |
| --- | --- | --- |
| `pihole-adblock-adlist.txt` | Plain domain list, one domain per line | Pi-hole adlist for ads / trackers |
| `pihole-adult-adlist.txt` | Plain domain list, one domain per line | Pi-hole adlist for adult / NSFW domains |
| `pihole-adlist.txt` | Plain domain list, one domain per line | Compatibility combined list for old/simple installs |

Simple explanation:

```text
pihole-adblock-adlist.txt = main adblock list
pihole-adult-adlist.txt   = main adult list
pihole-adlist.txt         = old combined compatibility list
```

## Use In Pi-hole

Add these two URLs to Pi-hole Adlists:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adblock-adlist.txt
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adult-adlist.txt
```

Then update gravity from the Pi-hole web UI, or run:

```bash
pihole -g
```

## Optional Combined URL

Use this only if you want one simple combined list instead of two separate lists:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adlist.txt
```

## Files

| File | Purpose |
| --- | --- |
| `pihole-adblock-adlist.txt` | Final generated Pi-hole adblock category list |
| `pihole-adult-adlist.txt` | Final generated Pi-hole adult category list |
| `pihole-adlist.txt` | Final generated combined compatibility list |
| `scripts/build-pihole-adlist.sh` | Downloads category core lists and builds Pi-hole outputs |
| `.github/workflows/update-pihole-adlist.yml` | Daily GitHub Actions build workflow |

## Build

```bash
./scripts/build-pihole-adlist.sh
```

The build script reads:

```text
core-domains.txt
core-adblock-domains.txt
core-adult-domains.txt
```

and generates Pi-hole-ready combined, adblock-only, and adult-only outputs.

## Signature

Generated items use this signature:

```text
managed-by=mohavise-pihole-adlist
project=mohavise-pihole-adlist
```

The signature makes future updates safer because generated outputs can be clearly identified as managed by this project.

## Update-Ready Approach

```text
Parent/core repo validates and publishes category lists.
Child repo converts category lists into Pi-hole-ready outputs.
Pi-hole refreshes the final output through Gravity.
Managed items are marked with a clear signature.
Future changes should update managed outputs only, not unrelated user configuration.
```

## Future Vision

```text
One clean parent system.
Separate category outputs.
Multiple child platform outputs.
Same timing.
Same signature style.
Safe daily updates.
Easy rollback and future category expansion.
```

Planned future categories can include malware, gambling, social media, crypto, telemetry, and other DNS/security feeds.

## Logic

```text
core-adblock-domains.txt → pihole-adblock-adlist.txt
core-adult-domains.txt   → pihole-adult-adlist.txt
core-domains.txt         → pihole-adlist.txt
```
