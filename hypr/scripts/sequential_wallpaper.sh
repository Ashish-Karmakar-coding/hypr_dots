#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/wallpapers"
HISTORY_FILE="$HOME/.last_wallpaper"

# 1. Ensure the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Directory $WALLPAPER_DIR does not exist."
    exit 1
fi

# 2. Get wallpapers (using mapfile to handle spaces in names correctly)
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    echo "No wallpapers found."
    exit 1
fi

# 3. Read history
LAST_WALL=$(cat "$HISTORY_FILE" 2>/dev/null)

# 4. Find next index
NEXT_INDEX=0
for i in "${!WALLPAPERS[@]}"; do
    if [[ "${WALLPAPERS[$i]}" == "$LAST_WALL" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#WALLPAPERS[@]} ))
        break
    fi
done

WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

# --- APPLICATION BLOCK ---

# OPTION A: Using swww (Recommended for modern animations)
# This solves the "bad path" and "unknown request" issues entirely.
if pgrep -x "swww-daemon" > /dev/null; then
    swww img "$WALLPAPER" --transition-type grow --transition-duration 1.5 --transition-fps 60
else
    # if swww isn't running, start it and set wall
    swww-daemon & sleep 0.5 && swww img "$WALLPAPER"
fi

# OPTION B: Using hyprpaper (If you prefer it, uncomment below and comment Option A)
# hyprctl hyprpaper unload all
# hyprctl hyprpaper preload "$WALLPAPER"
# hyprctl hyprpaper wallpaper ",$WALLPAPER"

# 5. Save history
echo "$WALLPAPER" > "$HISTORY_FILE"
