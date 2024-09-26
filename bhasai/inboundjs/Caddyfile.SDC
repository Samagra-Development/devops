handle_path /inboundjs* {
    reverse_proxy inboundjs:3000
}
