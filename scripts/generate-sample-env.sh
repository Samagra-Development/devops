#!/bin/bash

# Base directory to search for Docker Compose YAML files
BASE_DIRECTORY="${1:-..}"

# Function to extract environment variables from a docker-compose file
extract_env_vars() {
  echo "Processing file: $2"

  local tempfile=$(mktemp)
  
  
  # Extract variables and their defaults, then filter out unwanted ones
  grep -Eo '\${[^}]+}' "$2" | sed 's/[${}]//g' | \
  grep -Eo '^[^:-]+' | sort -u | \
  grep -Ev '(MEM_LIMIT|CPU_LIMIT|IMAGE_TAG|GITHUB_BRANCH)$' >> "$tempfile"

    # Check if the tempfile has content and is not empty
    if [[ -s "$tempfile" ]]; then
        local output_file="$1/sample.env"
        # Clear the output file if it exists
        > "$output_file"
        # Remove duplicate entries
        sort -u "$tempfile" -o "$output_file"
        echo "Environment variables have been extracted to $output_file"
    else
        echo "No environment variables found in the specified file."
    fi
}

# Check if the base directory exists
if [[ ! -d "$BASE_DIRECTORY" ]]; then
  echo "Directory $BASE_DIRECTORY does not exist."
  exit 1
fi

# Find all matching files in the base directory and its subdirectories
find "$BASE_DIRECTORY" -type f -name 'docker-compose*yaml' | while read -r file; do
  # Get the directory of the current docker-compose file
  dir=$(dirname "$file")
  # Extract environment variables and create sample.env in the corresponding directory
  extract_env_vars "$dir" "$file"
done

# Inform the user
echo "Processing completed. Check individual folders for sample.env files."