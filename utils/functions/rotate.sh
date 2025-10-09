rotate() {
    degree=${1:-90}  # Use first argument, default to 90 if not provided
    
    # Extract the output name (first word after "Output")
    output=$(swaymsg -t get_outputs | jq -r '.[0].name')
    swaymsg output "$output" transform "$degree"
}
