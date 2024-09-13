#!/bin/bash
# Join our telegram group t.me/efxtv
# Check if APK file is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-apk>"
    exit 1
fi

# Decompile APK
apktool d -f "$1"
echo
echo

# Define the function to format the output
format_lines() {
    sed -e '1s/^/IP: /' -e '2s/^/PORT: /'
}

# Set the directory where APK is decompiled
search_dir=$(basename "$1" .apk)

# Check if the decompiled directory exists
if [ ! -d "$search_dir" ]; then
    echo "Decompiled directory not found: $search_dir"
    exit 1
fi

# Extract and decode Base64 Strings
grep -rnw -e 'ClientPort' -e 'ClientHost' "$search_dir" | head -2 | awk '{print $NF}' | while read -r base64_str; do
    # Remove any extra characters or quotes
    base64_str=$(echo "$base64_str" | sed 's/^"\(.*\)"$/\1/')

    # Decode Base64 String
    decoded=$(echo "$base64_str" | base64 --decode 2>/dev/null)

    # Check if decoding was successful
    if [ $? -eq 0 ]; then
        # Print decoded strings with appropriate labels
        echo "$decoded"
    else
        echo "Error decoding Base64 string: $base64_str"
    fi
done | awk 'NR==1{print "IP   : " $0} NR==2{print "PORT : " $0}'

echo

# Extract line numbers and format them
grep -rnw -e 'ClientPort' -e 'ClientHost' "$search_dir" | head -2 | awk -F: '{print $1 " LINE NUMBER:" $2}'
