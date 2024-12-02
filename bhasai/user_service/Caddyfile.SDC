handle_path /user-service* {
    reverse_proxy user_service:3000
}
