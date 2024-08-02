handle_path /dataset-service* {
    reverse_proxy dataset_service:3000
}
