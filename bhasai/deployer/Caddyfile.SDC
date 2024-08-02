handle_path /deployer* {
    reverse_proxy deployer:3000
}
