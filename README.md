# Mohavise Pi-hole Adlist

Pi-hole-ready domain lists generated from the validated parent repository:

```text
mohavise-adblock-core
        ↓
mohavise-pihole-adlist
        ↓
Pi-hole Gravity
```

Source management, allowlists, custom blocks, and upstream validation are handled in:

```text
https://github.com/mohavise/mohavise-adblock-core
```

## Output Files

| File | Purpose |
| --- | --- |
| `pihole-adblock-adlist.txt` | Ads and trackers |
| `pihole-adult-adlist.txt` | Optional adult/NSFW blocking |
| `pihole-adlist.txt` | Combined compatibility list |

## Recommended Pi-hole Setup

Add the normal adblock list:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adblock-adlist.txt
```

Add the adult list only when adult/NSFW blocking is required:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adult-adlist.txt
```

Use the combined list only when you prefer one endpoint instead of separate categories:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adlist.txt
```

Do not add the combined list together with the two separate lists because that duplicates the same domains in Pi-hole.

After adding or changing an Adlist, update Gravity from the Pi-hole web interface or run:

```bash
pihole -g
```

## Build and Validation

The daily workflow reads:

```text
core-domains.txt
core-adblock-domains.txt
core-adult-domains.txt
```

The build process performs:

```text
Secure HTTPS download with retries and timeouts
→ lowercase normalization and duplicate removal
→ strict domain syntax validation
→ IP-address rejection
→ minimum-count checks
→ adblock/adult subset checks against the combined list
→ 20% sudden-drop protection against current published outputs
→ deterministic output generation
→ commit only when content changes
```

A failed validation stops the workflow before any generated output is committed.

Run the build locally with:

```bash
./scripts/build-pihole-adlist.sh
```

## Daily Automation

GitHub Actions runs at:

```text
00:00 UTC
```

Pi-hole downloads the latest published list whenever Gravity runs. Configure the Gravity schedule on the Pi-hole device according to your own maintenance window.

The workflow includes concurrency protection, a 15-minute timeout, and rebases before pushing to reduce scheduled-run conflicts.

## Managed Signature

Generated files begin with:

```text
# managed-by=mohavise-pihole-adlist
# project=mohavise-pihole-adlist
# do-not-edit-manually
```

## Repository Files

| File | Purpose |
| --- | --- |
| `scripts/build-pihole-adlist.sh` | Downloads, validates, and generates Pi-hole outputs |
| `.github/workflows/update-pihole-adlist.yml` | Daily automated build and commit workflow |
| `pihole-adblock-adlist.txt` | Normal adblock endpoint |
| `pihole-adult-adlist.txt` | Optional adult endpoint |
| `pihole-adlist.txt` | Combined compatibility endpoint |

## Cleanup Policy

Before removing repository files, read `CLEANUP_POLICY.md`. Generated outputs, compatibility files, workflows, and scripts are intentional parts of this project.
