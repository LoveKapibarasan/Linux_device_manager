copy_files() {
    APP_DIR="$1"
    sudo rm -rf "$APP_DIR"
    sudo mkdir -p "$APP_DIR"
    sudo cp -r . "$APP_DIR/"
}
