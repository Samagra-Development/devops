handle_path /auth-service* {
    reverse_proxy auth_service:3000
}
