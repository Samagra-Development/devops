#!/bin/bash

# Prompt messages
PROMPT_SERVICE_NAME="Enter Service Name: "
PROMPT_IMAGE_URL="Enter Image URL: "
PROMPT_SERVICE_PORT="Enter Service Port: "
EXPOSE_SERVICE="Enter Service Name to expose: "
ENTER_YOUR_CHOICE="Enter your choice: "
OUTPUT_INVALID_INPUT="Invalid input. Returning to the main menu."
OUTPUT_RETURN_MAIN_MENU="Returning to the main menu."
OUTPUT_SERVICE_NOT_FOUND="Service not found in docker-compose.yaml."

# Define an array for menu options
MENU_OPTIONS=(
  "Onboard a service"
  "Expose a service using Caddy"
  "Abort"
)

# Function to validate that the input is a number
validate_number() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. It must be a number."
    return 1
  else
    return 0
  fi
}

# Function to prompt the user for input and validate it
prompt_input() {
  local prompt_message=$1
  local validation_function=$2
  local input_variable=$3
  local input_value

  while true; do
    read -p "$prompt_message" input_value
    if [ -z "$validation_function" ] || $validation_function "$input_value"; then
      eval "$input_variable='$input_value'"
      break
    else
      echo "$OUTPUT_INVALID_INPUT"
    fi
  done
}

# Function to create or update docker-compose.yaml
update_docker_compose() {
  local template_file="service-template.yaml"
  local output_file="docker-compose.yaml"

  # Load the template content
  local template_content
  template_content=$(cat "$template_file")

  # Replace placeholders in the template with actual values
  template_content="${template_content//SERVICE_NAME/$SERVICE_NAME}"
  template_content="${template_content//IMAGE_URL/${IMAGE_URL}}"

  # Replace DEMO_SERVICE with SERVICE_NAME
  template_content="${template_content//DEMO_SERVICE/$SERVICE_NAME}"

  # Convert the template content to a valid YAML structure
  local service_yaml
  service_yaml=$(echo "$template_content" | yq eval -o=json | jq -c '.services')

  # Check if the file exists and append the service
  if [ -f "$output_file" ]; then
    echo -e "\n" >> "$output_file"
    yq eval -i ".services += $service_yaml" "$output_file"
  else
    touch "$output_file"
    echo "$service_yaml" | yq eval -o=json | jq -c '.services' | yq eval -i ".services = $service_yaml" "$output_file"
  fi
}

# Function to create or update Caddyfile
update_caddyfile() {
  local service_name=$1
  local service_port=$2
  local caddy_entry="\${DOMAIN_SCHEME}://${service_name}.\${DOMAIN_NAME} {
  reverse_proxy ${service_name}:${service_port}
}"

  if [ -f "Caddyfile" ]; then
    if grep -q "$service_name" "Caddyfile"; then
      echo "Service $service_name is already exposed in Caddyfile."
    else
      echo -e "\n$caddy_entry" >> Caddyfile
      echo "Added $service_name to Caddyfile."
    fi
  else
    echo -e "$caddy_entry" > Caddyfile
    echo "Caddyfile created and $service_name added."
  fi
}

# Function to expose a service in Caddyfile
expose_service() {
  local service_name=$1
  local service_port=$2

  # Check if the file docker-compose.yaml exists
  if [ ! -f "docker-compose.yaml" ]; then
    echo "docker-compose.yaml not found."
    echo "$OUTPUT_SERVICE_NOT_FOUND"
    return
  fi

  # Check if the service exists in docker-compose.yaml
  local service_exists
  service_exists=$(yq eval ".services | has(\"$service_name\")" docker-compose.yaml)

  if [ "$service_exists" = "true" ]; then
    echo "Service $service_name found."

    # Update the Caddyfile with the provided port
    update_caddyfile "$service_name" "$service_port"
  else
    # Use printf to include the service name in the output message
    printf "%s %s\n" "$service_name" "$OUTPUT_SERVICE_NOT_FOUND"
  fi
}

# Function to handle onboarding a service
onboard_service() {
  prompt_input "$PROMPT_SERVICE_NAME" "" SERVICE_NAME
  prompt_input "$PROMPT_IMAGE_URL" "" IMAGE_URL

  update_docker_compose
}

# Function to display the main menu
display_main_menu() {
  echo
  echo "Choose an option:"
  for i in "${!MENU_OPTIONS[@]}"; do
    echo "$((i + 1))) ${MENU_OPTIONS[$i]}"
  done
  echo
}

# Main menu
while true; do
  display_main_menu
  read -p "$ENTER_YOUR_CHOICE" choice

  case "$choice" in
    1) onboard_service;;
    2) 
      read -p "$EXPOSE_SERVICE" expose_service_name
      prompt_input "$PROMPT_SERVICE_PORT" validate_number expose_service_port
      expose_service "$expose_service_name" "$expose_service_port"
      ;;
    3) echo "Aborting."; exit 0;;
    *) echo "$OUTPUT_INVALID_INPUT";;
  esac
done
