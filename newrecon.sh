!/bin/bash

# Purpose: Subdomain discovery, live host probing, and Nmap scanning

TARGET="tesla.com"
OUTPUT_DIR="tesla"

mkdir -p "$OUTPUT_DIR"

echo "[+] [newrecon1] Finding subdomains using Subfinder..."
subfinder -d "$TARGET" -silent > "$OUTPUT_DIR/subfinder.txt"

echo "[+] [newrecon1] Finding subdomains using Amass..."
amass enum -d "$TARGET" -o "$OUTPUT_DIR/amass.txt"

echo "[+] [newrecon1] Combining and deduplicating subdomains..."
cat "$OUTPUT_DIR/subfinder.txt" "$OUTPUT_DIR/amass.txt" | sort -u > "$OUTPUT_DIR/all_subdomains.txt"

echo "[+] [newrecon1] Probing live subdomains with httprobe..."
cat "$OUTPUT_DIR/all_subdomains.txt" | httprobe > "$OUTPUT_DIR/live_subdomains.txt"

echo "[+] [newrecon1] Running Nmap scans on live subdomains..."
while read url; do
    host=$(echo $url | sed 's|https\?://||')
    echo "[+] [newrecon1] Scanning $host with Nmap..."
    nmap -T4 -A "$host" -oN "$OUTPUT_DIR/nmap_$host.txt"
done < "$OUTPUT_DIR/live_subdomains.txt"

echo "[+] [newrecon1] Recon complete. Results saved in $OUTPUT_DIR."
