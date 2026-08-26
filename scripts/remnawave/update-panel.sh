#!/bin/bash

source "/opt/Noderepkot/scripts/common/colors.sh"
source "/opt/Noderepkot/scripts/common/functions.sh"
source "/opt/Noderepkot/scripts/common/languages.sh"

update_panel() {
    info "$(get_string update_panel_updating)"
    cd /opt/remnawave
    docker compose pull
    docker compose down
    docker compose up -d
    success "$(get_string update_panel_complete)"
}

main() {
    update_panel
    read -n 1 -s -r -p "$(get_string update_panel_press_key)"
    exit 0
}

main
