handle_path /document-service* {
    reverse_proxy document_service:3000
}
