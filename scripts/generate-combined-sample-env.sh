#!/bin/bash

# Base directory to search for Docker Compose YAML files
BASE_DIRECTORY="${1:-..}"

# Output file
OUTPUT_FILE="sample.env"

# Clear the output file
> "$OUTPUT_FILE"

# Function to extract environment variables from a docker-compose file
extract_env_vars() {
  echo "Processing file: $1"
  # Extract variables and their defaults, then filter out unwanted ones
  grep -Eo '\${[^}]+}' "$1" | sed 's/[${}]//g' | \
  grep -Eo '^[^:-]+' | sort -u  | \
  grep -Ev '(MEM_LIMIT|CPU_LIMIT|IMAGE_TAG|GITHUB_BRANCH)$' >> "$OUTPUT_FILE"
}

# Check if the base directory exists
if [[ ! -d "$BASE_DIRECTORY" ]]; then
  echo "Directory $BASE_DIRECTORY does not exist."
  exit 1
fi

# Find all matching files in the base directory and its subdirectories
find "$BASE_DIRECTORY" -type f -name 'docker-compose*yaml' | while read -r file; do
  extract_env_vars "$file"
done

# Check if OUTPUT_FILE has content
if [[ -s "$OUTPUT_FILE" ]]; then
  # Remove duplicate entries
  sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"
  echo "Environment variables have been extracted to $OUTPUT_FILE"
else
  echo "No environment variables found in the specified files."
fi