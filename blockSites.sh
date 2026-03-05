#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAINS_DIR="$SCRIPT_DIR/domains"
HOSTS_FILE="/etc/hosts"

# Collect available site configs
site_files=()
site_names=()
for f in "$DOMAINS_DIR"/*.txt; do
    [[ -f "$f" ]] || continue
    site_files+=("$f")
    site_names+=("$(basename "$f" .txt)")
done

if [[ ${#site_files[@]} -eq 0 ]]; then
    echo "No domain files found in $DOMAINS_DIR"
    exit 1
fi

# Display menu
echo ""
echo "Available sites to block:"
echo "─────────────────────────"
for i in "${!site_names[@]}"; do
    printf "  [%d] %s\n" "$((i + 1))" "${site_names[$i]}"
done
echo "─────────────────────────"
echo "  [a] all"
echo ""
read -rp "Enter numbers to block (e.g. 1 3), or 'a' for all: " selection

# Resolve selected files
selected_files=()
if [[ "$selection" == "a" || "$selection" == "all" ]]; then
    selected_files=("${site_files[@]}")
else
    for token in $selection; do
        if [[ "$token" =~ ^[0-9]+$ ]] && (( token >= 1 && token <= ${#site_files[@]} )); then
            selected_files+=("${site_files[$((token - 1))]}")
        else
            echo "Skipping invalid selection: $token"
        fi
    done
fi

if [[ ${#selected_files[@]} -eq 0 ]]; then
    echo "Nothing selected. Exiting."
    exit 0
fi

# Block selected sites
echo ""
for domain_file in "${selected_files[@]}"; do
    site="$(basename "$domain_file" .txt)"
    echo "Blocking: $site"
    added=0
    already=0

    while IFS= read -r domain || [[ -n "$domain" ]]; do
        [[ -z "$domain" || "$domain" == \#* ]] && continue

        for entry in "127.0.0.1 $domain" "::1 $domain"; do
            if grep -qF "$entry" "$HOSTS_FILE"; then
                (( already++ ))
            else
                echo "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
                (( added++ ))
            fi
        done
    done < "$domain_file"

    echo "  ✓ $added entries added, $already already blocked"
done

echo ""
echo "Done."
