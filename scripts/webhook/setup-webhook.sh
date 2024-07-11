#!/bin/bash

set -eo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(cd $SCRIPT_DIR/../../ && pwd && cd --)
SERVICE_FILE="/etc/systemd/system/webhook.service"
TEMPLATE_FILE="$PROJECT_ROOT/scripts/webhook/webhook.service.template"


echo "Setup webhook"
if ! command -v webhook &> /dev/null; then 
    echo "Installing webhook"; 
sudo -- sh -c  'curl -sSL  https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz | \
tar -zxvf - --strip-components=1 --directory /usr/local/bin/  webhook-linux-amd64/webhook' 
else 
    echo "Webhook is already installed"; 
fi


echo "Creating systemd service file"
cp "$TEMPLATE_FILE" "$SERVICE_FILE"

echo "Starting  Webhook"
source <(grep "^WEBHOOK_PASSWORD=" .env)
if [ -z "$WEBHOOK_PASSWORD" ]; then
    echo "ERROR: WEBHOOK_PASSWORD is not defined in .env"
    exit 1
fi

sed -i "s|\${PROJECT_DIR}|$(pwd)|g" "$SERVICE_FILE"
sed -i "s|\${WEBHOOK_USER}|$(whoami)|g" "$SERVICE_FILE"
sed -i "s|\${WEBHOOK_GROUP}|$(id -gn)|g" "$SERVICE_FILE"

sudo systemctl daemon-reload
sudo systemctl enable --now webhook.service

echo "Webhook service started and enabled"