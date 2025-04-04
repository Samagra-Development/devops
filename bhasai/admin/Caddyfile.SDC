handle_path /admin* {
    reverse_proxy admin:3000
}
