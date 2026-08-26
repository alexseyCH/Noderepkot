#!/bin/bash

source "/opt/Noderepkot/scripts/common/colors.sh"
source "/opt/Noderepkot/scripts/common/functions.sh"
source "/opt/Noderepkot/scripts/common/languages.sh"

update_subscription() {
    info "$(get_string update_subscription_updating)"
    cd /opt/remnawave/subscription
    docker compose pull
    docker compose down
    docker compose up -d
    success "$(get_string update_subscription_complete)"
}

main() {
    update_subscription
    read -n 1 -s -r -p "$(get_string update_subscription_press_key)"
    exit 0
}

main
