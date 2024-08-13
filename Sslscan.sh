#!/bin/bash

# Check if the user provided the input file containing domains
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE=$1

# Check if sslscan is installed
if ! command -v sslscan &> /dev/null
then
    echo "sslscan could not be found. Please install sslscan and try again."
    exit 1
fi

# Create a directory to store the results
OUTPUT_DIR="sslscan_results"
mkdir -p "$OUTPUT_DIR"

# Loop through each domain in the input file
while IFS= read -r domain
do
    if [ -n "$domain" ]; then
        echo "Scanning $domain..."
        OUTPUT_FILE="$OUTPUT_DIR/${domain//:/_}.txt"
        sslscan "$domain" > "$OUTPUT_FILE"
        echo "Results saved to $OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

echo "SSL scan completed for all domains in $INPUT_FILE."
