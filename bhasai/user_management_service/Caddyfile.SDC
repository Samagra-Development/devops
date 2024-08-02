handle_path /user-management-service* {
    reverse_proxy user_management_service:3000
}
