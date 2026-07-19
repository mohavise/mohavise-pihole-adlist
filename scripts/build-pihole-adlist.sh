#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

CORE_URL="${CORE_URL:-https://raw.githubusercontent.com/mohavise/mohavise-adblock-core/main/core-domains.txt}"
CORE_ADBLOCK_URL="${CORE_ADBLOCK_URL:-https://raw.githubusercontent.com/mohavise/mohavise-adblock-core/main/core-adblock-domains.txt}"
CORE_ADULT_URL="${CORE_ADULT_URL:-https://raw.githubusercontent.com/mohavise/mohavise-adblock-core/main/core-adult-domains.txt}"

DOMAIN_OUTPUT_FILE="${DOMAIN_OUTPUT_FILE:-$REPO_DIR/pihole-adlist.txt}"
PIHOLE_ADBLOCK_OUTPUT_FILE="${PIHOLE_ADBLOCK_OUTPUT_FILE:-$REPO_DIR/pihole-adblock-adlist.txt}"
PIHOLE_ADULT_OUTPUT_FILE="${PIHOLE_ADULT_OUTPUT_FILE:-$REPO_DIR/pihole-adult-adlist.txt}"

MIN_DOMAIN_COUNT="${MIN_DOMAIN_COUNT:-10000}"
MIN_ADBLOCK_DOMAIN_COUNT="${MIN_ADBLOCK_DOMAIN_COUNT:-10000}"
MIN_ADULT_DOMAIN_COUNT="${MIN_ADULT_DOMAIN_COUNT:-1000}"
MAX_DROP_PERCENT="${MAX_DROP_PERCENT:-20}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fetch_domains() {
    local source_url="$1"
    local output_file="$2"

    if [[ -f "$source_url" ]]; then
        cat "$source_url"
    else
        curl --fail --silent --show-error --location \
            --retry 3 --retry-all-errors --connect-timeout 15 --max-time 180 \
            "$source_url"
    fi |
        awk '
            {
                line = tolower($0)
                sub(/\r$/, "", line)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
                if (line != "" && line !~ /^#/) print line
            }
        ' |
        LC_ALL=C sort -u > "$output_file"
}

validate_domains() {
    local file="$1"
    local label="$2"

    python3 - "$file" "$label" <<'PY'
import ipaddress
import re
import sys

path, label = sys.argv[1:]
label_re = re.compile(r"^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$")
errors = []

with open(path, encoding="utf-8") as handle:
    for line_number, raw in enumerate(handle, 1):
        domain = raw.rstrip("\n")

        if not domain or domain != domain.strip() or any(ch.isspace() for ch in domain):
            errors.append((line_number, domain, "empty or contains whitespace"))
            continue

        if len(domain) > 253 or domain.endswith("."):
            errors.append((line_number, domain, "invalid total length or trailing dot"))
            continue

        try:
            ipaddress.ip_address(domain)
        except ValueError:
            pass
        else:
            errors.append((line_number, domain, "IP address is not a domain"))
            continue

        labels = domain.split(".")
        if len(labels) < 2 or any(not label_re.fullmatch(item) for item in labels):
            errors.append((line_number, domain, "invalid domain syntax"))

        if len(errors) >= 20:
            break

if errors:
    print(f"{label} contains invalid entries:", file=sys.stderr)
    for line_number, domain, reason in errors:
        print(f"  line {line_number}: {domain!r} ({reason})", file=sys.stderr)
    sys.exit(1)
PY
}

validate_min_count() {
    local file="$1"
    local minimum="$2"
    local label="$3"
    local count

    count="$(wc -l < "$file" | tr -d ' ')"
    if (( count < minimum )); then
        echo "$label domain count $count is below minimum $minimum; refusing to overwrite outputs." >&2
        exit 1
    fi

    echo "$count"
}

validate_sudden_drop() {
    local new_file="$1"
    local current_file="$2"
    local label="$3"

    [[ -f "$current_file" ]] || return 0

    local old_count new_count minimum_allowed
    old_count="$(awk 'NF && $0 !~ /^#/ { count++ } END { print count + 0 }' "$current_file")"
    new_count="$(wc -l < "$new_file" | tr -d ' ')"

    (( old_count > 0 )) || return 0
    minimum_allowed=$(( old_count * (100 - MAX_DROP_PERCENT) / 100 ))

    if (( new_count < minimum_allowed )); then
        echo "$label domain count fell from $old_count to $new_count, more than ${MAX_DROP_PERCENT}%; refusing to overwrite outputs." >&2
        exit 1
    fi
}

validate_subset() {
    local subset_file="$1"
    local combined_file="$2"
    local label="$3"
    local missing_file="$TMP_DIR/missing-$RANDOM.txt"

    comm -23 "$subset_file" "$combined_file" > "$missing_file"
    if [[ -s "$missing_file" ]]; then
        echo "$label contains domains missing from the combined core list; refusing to overwrite outputs." >&2
        head -n 20 "$missing_file" >&2
        exit 1
    fi
}

write_pihole_file() {
    local input_file="$1"
    local output_file="$2"
    local temporary_output="$TMP_DIR/$(basename "$output_file").new"

    {
        echo "# managed-by=mohavise-pihole-adlist"
        echo "# project=mohavise-pihole-adlist"
        echo "# do-not-edit-manually"
        cat "$input_file"
    } > "$temporary_output"

    mv "$temporary_output" "$output_file"
}

fetch_domains "$CORE_URL" "$TMP_DIR/combined.txt"
fetch_domains "$CORE_ADBLOCK_URL" "$TMP_DIR/adblock.txt"
fetch_domains "$CORE_ADULT_URL" "$TMP_DIR/adult.txt"

validate_domains "$TMP_DIR/combined.txt" "Combined core"
validate_domains "$TMP_DIR/adblock.txt" "Adblock core"
validate_domains "$TMP_DIR/adult.txt" "Adult core"

combined_count="$(validate_min_count "$TMP_DIR/combined.txt" "$MIN_DOMAIN_COUNT" "Combined core")"
adblock_count="$(validate_min_count "$TMP_DIR/adblock.txt" "$MIN_ADBLOCK_DOMAIN_COUNT" "Adblock core")"
adult_count="$(validate_min_count "$TMP_DIR/adult.txt" "$MIN_ADULT_DOMAIN_COUNT" "Adult core")"

validate_subset "$TMP_DIR/adblock.txt" "$TMP_DIR/combined.txt" "Adblock core"
validate_subset "$TMP_DIR/adult.txt" "$TMP_DIR/combined.txt" "Adult core"

validate_sudden_drop "$TMP_DIR/combined.txt" "$DOMAIN_OUTPUT_FILE" "Combined core"
validate_sudden_drop "$TMP_DIR/adblock.txt" "$PIHOLE_ADBLOCK_OUTPUT_FILE" "Adblock core"
validate_sudden_drop "$TMP_DIR/adult.txt" "$PIHOLE_ADULT_OUTPUT_FILE" "Adult core"

write_pihole_file "$TMP_DIR/combined.txt" "$DOMAIN_OUTPUT_FILE"
write_pihole_file "$TMP_DIR/adblock.txt" "$PIHOLE_ADBLOCK_OUTPUT_FILE"
write_pihole_file "$TMP_DIR/adult.txt" "$PIHOLE_ADULT_OUTPUT_FILE"

echo "Generated combined Pi-hole adlist with $combined_count blocked domains."
echo "Generated adblock Pi-hole adlist with $adblock_count blocked domains."
echo "Generated adult Pi-hole adlist with $adult_count blocked domains."
