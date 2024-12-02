handle_path /transport-socket* {
    reverse_proxy transport_socket:3000
}
