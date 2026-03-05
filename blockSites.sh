#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAINS_DIR="$SCRIPT_DIR/domains"
HOSTS_FILE="/etc/hosts"

for domain_file in "$DOMAINS_DIR"/*.txt; do
    while IFS= read -r domain || [[ -n "$domain" ]]; do
        # Skip empty lines and comments
        [[ -z "$domain" || "$domain" == \#* ]] && continue

        for entry in "127.0.0.1 $domain" "::1 $domain"; do
            if ! grep -qF "$entry" "$HOSTS_FILE"; then
                echo "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
            fi
        done
    done < "$domain_file"
done
