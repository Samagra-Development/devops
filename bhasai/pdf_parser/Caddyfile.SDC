handle_path /pdf-parser* {
    reverse_proxy pdf_parser:8000
}
