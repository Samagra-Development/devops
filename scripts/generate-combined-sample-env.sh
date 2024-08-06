#!/bin/bash

# Base directory to search for Docker Compose YAML files
BASE_DIRECTORIES=("${@}")

# Output file
OUTPUT_FILE="sample.env"

# Clear the output file
> "$OUTPUT_FILE"

# Function to extract environment variables from a docker-compose file
extract_env_vars() {
  echo "Processing file: $1"
  # Extract variables and their defaults, then filter out unwanted ones 
  grep -Eo '\${[^}]+}' "$1" | sed -e 's/[${}]//g' -e 's/:-\([^$]*\)/=\1/' | \
  grep -Eo '^[^:-]+' | sort -u  | \
  grep -Ev '(MEM_LIMIT|CPU_LIMIT|IMAGE_TAG|GITHUB_BRANCH)$' >> "$OUTPUT_FILE"
}


# Iterate over each base directory
for BASE_DIRECTORY in "${BASE_DIRECTORIES[@]}"; do
  # Check if the base directory exists
  if [[ ! -d "$BASE_DIRECTORY" ]]; then
    echo "Directory $BASE_DIRECTORY does not exist."
    continue
  fi

  # Find all matching files in the base directory and its subdirectories
  find "$BASE_DIRECTORY" -type f -name 'docker-compose*yaml' | while read -r file; do
    extract_env_vars "$file"
  done
done

# Check if OUTPUT_FILE has content
if [[ -s "$OUTPUT_FILE" ]]; then
  # Remove duplicate entries and sort
  sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"
  
  # Sort lines with '=' to the top and lines without '=' to the bottom
(grep '=' "$OUTPUT_FILE"; grep -v '=' "$OUTPUT_FILE") > temp_output && mv temp_output "$OUTPUT_FILE"
  
  echo "Environment variables have been extracted to $OUTPUT_FILE"
else
  echo "No environment variables found in the specified files."
fi