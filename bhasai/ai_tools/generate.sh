#!/bin/bash
set -e

##################################################################################################
# Description: This script generates Docker Compose and Caddy configuration                      #
#              files based on a AI_SERVICES environment variable                                 #
#                                                                                                #
# Required Environment Variables:                                                                #
#   - org: GitHub organization                                                                   #
#   - DOCKER_REGISTRY_URL: Docker registry to use for the container images (default: 'ghcr.io')  #
##################################################################################################


source .env

required_env=("org" "DOCKER_REGISTRY_URL" "AI_SERVICES")

# Check if required environment variables are set
for var in "${required_env[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: '$var' environment variable is not set."
        exit 1
    fi
done

directory="bhasai/ai_tools"

GITHUB_REPOSITORY_URL="${org}/ai-tools"
GITHUB_BRANCH="${AI_TOOLS_GITHUB_BRANCH:-${DEFAULT_GITHUB_BRANCH?DEFAULT_GITHUB_BRANCH is not set}}"

command -v jq >/dev/null || { echo "Error: jq is required but not found. Please install it."; exit 1; }

# Get the number of models from the config.json file
count=$(echo "$AI_SERVICES" | jq -r '.models | length')
ComposeFile="${directory}/docker-compose.yaml"
Caddyfile="${directory}/Caddyfile"
CaddyfileSDC="${directory}/Caddyfile.SDC"

# Generate docker-compose.yaml file
printf "services:\n" > $ComposeFile

printf '{$DOMAIN_SCHEME}://ai-tools.{$DOMAIN_NAME} {' > $Caddyfile
printf "" > $CaddyfileSDC

# Loop through each model
for ((i=0; i<$count; i++)); do
    # Get model details from config.json
    serviceName=$(echo "$AI_SERVICES" | jq -r ".models[$i].serviceName")
    apiBasePath=$(echo "$AI_SERVICES" | jq -r ".models[$i].apiBasePath")
    containerPort=$(echo "$AI_SERVICES" | jq -r ".models[$i].containerPort")
    gpu=$(echo "$AI_SERVICES" | jq ".models[$i].gpu")

    containerImage="${DOCKER_REGISTRY_URL}/${GITHUB_REPOSITORY_URL}/${serviceName}:\${AI_TOOLS_IMAGE_TAG:-\${DEFAULT_IMAGE_TAG:?DEFAULT_IMAGE_TAG is not set}}"

    echo "handle_path /ai-tools/${apiBasePath}* {
    reverse_proxy ${serviceName}:${containerPort}
}" >> $CaddyfileSDC

    echo "
    handle_path /${apiBasePath}* {
        reverse_proxy ${serviceName}:${containerPort}
    }
    " >> $Caddyfile


    # Get environment variables for the model
    environment=($(echo "$AI_SERVICES" | jq -r ".models[$i].environment | keys[]"))
    
    # Add service details to docker-compose.yaml

    printf "  ${serviceName}:\n    image: $containerImage\n    restart: always\n" >> $ComposeFile
        # Add environment variables to docker-compose.yaml
    if [[ ${#environment[@]} -gt 0 ]]; then
        printf "    environment:\n" >> $ComposeFile
    fi
    for key in "${environment[@]}"; do
        printf "      - ${key}=\${${key}}\n" >> $ComposeFile
    done

    if [[ "$gpu" == 'true' ]] ;then

    printf "    deploy:\n      resources:\n        reservations:\n          devices:\n            - driver: nvidia\n              count: 1\n              capabilities: [gpu]\n" >> $ComposeFile

    fi
    printf "\n" >> $ComposeFile
    
done
printf "}" >> $Caddyfile
