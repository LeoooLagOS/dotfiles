#!/bin/bash

RAW_FILE="/tmp/cover_raw"
ART_FILE="/tmp/cover.png"
MODE="$1"

# 1. ROBUST PLAYER DETECTION
STATUS=$(playerctl -p spotify,%any status 2>/dev/null)

if [[ "$STATUS" == "Playing" ]]; then
    
    # TEXT DATA
    if [[ "$MODE" == "title" ]]; then
        playerctl -p spotify,%any metadata title | cut -c 1-40
    elif [[ "$MODE" == "artist" ]]; then
        playerctl -p spotify,%any metadata artist | cut -c 1-40
    elif [[ "$MODE" == "album" ]]; then
        playerctl -p spotify,%any metadata album | cut -c 1-40
        
    # ALBUM ART
    elif [[ "$MODE" == "art" ]]; then
        URL=$(playerctl -p spotify,%any metadata mpris:artUrl 2>/dev/null)
        
        if [[ -n "$URL" ]]; then
            # Download
            if [[ "$URL" == file://* ]]; then
                cp "${URL#file://}" "$RAW_FILE"
            elif [[ "$URL" == http* ]]; then
                curl -s -o "$RAW_FILE" "$URL"
            fi
            
            # Convert: Resize to 200x200, Add 2px White Border
            if [[ -f "$RAW_FILE" ]]; then
                magick "$RAW_FILE" -resize 200x200^ -gravity center -extent 200x200 \
                       -bordercolor "rgba(255,255,255,0.6)" -border 2 \
                       "$ART_FILE"
            fi
            
            echo "$ART_FILE"
        fi
    fi

else
    # STOPPED / PAUSED
    if [[ "$MODE" == "title" ]] || [[ "$MODE" == "artist" ]] || [[ "$MODE" == "album" ]]; then
        echo ""
    elif [[ "$MODE" == "art" ]]; then
        # GENERATE TRANSPARENT SQUARE
        # We explicitly create a 200x200 transparent image.
        # This replaces the old album art completely.
        magick -size 200x200 xc:none "$ART_FILE"
        echo "$ART_FILE"
    fi
fi