handle_path /ai-tools-proxy* {
    reverse_proxy ai_tools_proxy:3000
}
