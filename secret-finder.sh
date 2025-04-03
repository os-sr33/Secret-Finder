#!/bin/bash

echo -e "\e[1;32m
   ____                     _        _____ _           _           
  / ___|  ___  ___ _ __ ___| |_     |  ___(_)_ __   __| | ___ _ __ 
  \___ \ / _ \/ __| '__/ _ \ __|____| |_  | | '_ \ / _\` |/ _ \ '__|
   ___) |  __/ (__| | |  __/ ||_____|  _| | | | | | (_| |  __/ |   
  |____/ \___|\___|_|  \___|\__|    |_|   |_|_| |_|\__,_|\___|_|   
\e[0m"

echo -e "\e[1;34mA powerful tool to uncover hidden secrets in code and applications!\e[0m"


# Check if a target URL is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <target-website>"
    exit 1
fi

TARGET="$1"
OUTPUT_DIR="js_files"
JS_LINKS="js_links.txt"
FOUND_SECRETS="found_secrets.txt"

# Create a directory to store downloaded JS files
mkdir -p "$OUTPUT_DIR"

echo "[+] Finding JavaScript files from $TARGET using Katana, WaybackURLs, and GAU..."

# Run Katana to discover JS files
katana -u "$TARGET" -jc -silent | grep "\.js$" | tee "$JS_LINKS"

# Use waybackurls to get historical JS files
waybackurls "$TARGET" | grep "\.js$" | tee -a "$JS_LINKS"

# Use gau (Get All URLs) to fetch more JS files
gau "$TARGET" | grep "\.js$" | tee -a "$JS_LINKS"

# Remove duplicates
sort -u "$JS_LINKS" -o "$JS_LINKS"

echo "[+] Downloading JavaScript files..."
while read -r url; do
    wget -q "$url" -P "$OUTPUT_DIR"
done < "$JS_LINKS"

echo "[+] Scanning for hardcoded secrets..."
> "$FOUND_SECRETS"  # Clear the output file before scanning

# Define regex patterns for secrets
PATTERNS='(apikey|secret|token|password|auth|client_id|client_secret)[[:space:]]*[:=][[:space:]]*["'"'"']?([A-Za-z0-9_.\/+=-]{10,})(?![();])'


# Prepare table header
echo -e "\n\033[1;32m+---------------------+--------------------------------------------+\033[0m"
echo -e "\033[1;32m| JavaScript File    | Found Secret                                |\033[0m"
echo -e "\033[1;32m+---------------------+--------------------------------------------+\033[0m"

# Loop through each JS file and search for secrets
for file in "$OUTPUT_DIR"/*.js; do
   grep -iPo '(apikey|secret|token|password|auth|client_id|client_secret)\s*[:=]\s*["'"'"']?\K[A-Za-z0-9_.\/+=-]{10,}' "$file" | while read -r secret; do
 secret=$(echo "$match" | cut -d '=' -f2 | tr -d ':"' | xargs)  # Extract secret
        if [[ -n "$secret" ]]; then
            printf "| %-19s | %-40s |\n" "$(basename "$file")" "$secret"
            echo "$(basename "$file") | $secret" >> "$FOUND_SECRETS"
        fi
    done
done

echo -e "\033[1;32m+---------------------+--------------------------------------------+\033[0m"

echo "[+] Scan complete! Results saved in found_secrets.txt"
