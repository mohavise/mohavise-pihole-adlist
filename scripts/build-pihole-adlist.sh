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

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fetch_domains() {
    local source_url="$1"
    local output_file="$2"

    if [[ -f "$source_url" ]]; then
        cat "$source_url"
    else
        curl -fsSL "$source_url"
    fi |
        awk '
            {
                line = tolower($0)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
                if (line != "" && line !~ /^#/) print line
            }
        ' |
        sort -u > "$output_file"
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

write_pihole_file() {
    local input_file="$1"
    local output_file="$2"

    {
        echo "# managed-by=mohavise-pihole-adlist"
        echo "# project=mohavise-pihole-adlist"
        echo "# do-not-edit-manually"
        echo "# generated-at=$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
        cat "$input_file"
    } > "$output_file"
}

fetch_domains "$CORE_URL" "$TMP_DIR/combined.txt"
fetch_domains "$CORE_ADBLOCK_URL" "$TMP_DIR/adblock.txt"
fetch_domains "$CORE_ADULT_URL" "$TMP_DIR/adult.txt"

combined_count="$(validate_min_count "$TMP_DIR/combined.txt" "$MIN_DOMAIN_COUNT" "Combined core")"
adblock_count="$(validate_min_count "$TMP_DIR/adblock.txt" "$MIN_ADBLOCK_DOMAIN_COUNT" "Adblock core")"
adult_count="$(validate_min_count "$TMP_DIR/adult.txt" "$MIN_ADULT_DOMAIN_COUNT" "Adult core")"

write_pihole_file "$TMP_DIR/combined.txt" "$DOMAIN_OUTPUT_FILE"
write_pihole_file "$TMP_DIR/adblock.txt" "$PIHOLE_ADBLOCK_OUTPUT_FILE"
write_pihole_file "$TMP_DIR/adult.txt" "$PIHOLE_ADULT_OUTPUT_FILE"

echo "Generated combined Pi-hole adlist with $combined_count blocked domains."
echo "Generated adblock Pi-hole adlist with $adblock_count blocked domains."
echo "Generated adult Pi-hole adlist with $adult_count blocked domains."
