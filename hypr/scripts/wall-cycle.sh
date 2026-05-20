#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers/"
HISTORY_FILE="$HOME/.last_wallpaper"

# Get the list of wallpapers sorted alphabetically
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f | sort))

# Stop if no wallpapers are found
if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Read the last used wallpaper
if [[ -f "$HISTORY_FILE" ]]; then
    LAST_WALL=$(cat "$HISTORY_FILE")
else
    LAST_WALL=""
fi

# Find the next wallpaper in the list
NEXT_INDEX=0
for i in "${!WALLPAPERS[@]}"; do
    if [[ "${WALLPAPERS[$i]}" == "$LAST_WALL" ]]; then
        NEXT_INDEX=$((i + 1))
        break
    fi
done

# Loop back to the first wallpaper if we reached the end
if [[ $NEXT_INDEX -ge ${#WALLPAPERS[@]} ]]; then
    NEXT_INDEX=0
fi

# Set the new wallpaper variable and save it for next time
WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"
echo "$WALLPAPER" > "$HISTORY_FILE"

# ==========================================
# Application Logic (swww vs hyprpaper)
# ==========================================

# Check if swww is running
if pgrep -x swww-daemon > /dev/null || pgrep -x swww > /dev/null; then
    # Use swww for a smooth wipe transition
    swww img "$WALLPAPER" --transition-type wipe --transition-angle 30 --transition-step 90

# Check if hyprpaper is running instead
elif pgrep -x hyprpaper > /dev/null; then
    # Load new, apply, then unload old (fixes the flashing bug)
    hyprctl hyprpaper preload "$WALLPAPER"
    hyprctl hyprpaper wallpaper ",$WALLPAPER"
    if [[ -n "$LAST_WALL" ]]; then
        hyprctl hyprpaper unload "$LAST_WALL"
    fi
else
    echo "Error: Neither swww nor hyprpaper is running in the background!"
fi
