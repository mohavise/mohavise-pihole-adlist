# Mohavise Pi-hole Adlist

Pi-hole child/output repo for the Mohavise adblock system.

It publishes one Pi-hole-ready adlist from the validated core list.

## Source

```text
https://github.com/mohavise/mohavise-adblock-core
```

## Output

```text
pihole-adblock-adlist.txt
```

Raw URL:

```text
https://raw.githubusercontent.com/mohavise/mohavise-pihole-adlist/main/pihole-adblock-adlist.txt
```

## Use in Pi-hole

Add the raw URL to Pi-hole Adlists, then update Gravity:

```bash
pihole -g
```

## Files

```text
pihole-adblock-adlist.txt
scripts/build-pihole-adlist.sh
.github/workflows/update-pihole-adlist.yml
```
