#!/bin/bash

# Script to convert all images in the figure directory to JPG format
# with a maximum file size of 100 kB

set -e  # Exit on error

FIGURE_DIR="$(dirname "$0")/../figure"
MAX_SIZE_KB=100
MAX_SIZE_BYTES=$((MAX_SIZE_KB * 1024))

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    echo "On Ubuntu/Debian: sudo apt-get install imagemagick"
    exit 1
fi

# Use 'magick' if available (newer ImageMagick), otherwise 'convert'
if command -v magick &> /dev/null; then
    CONVERT_CMD="magick"
else
    CONVERT_CMD="convert"
fi

# Check if figure directory exists
if [ ! -d "$FIGURE_DIR" ]; then
    echo "Error: Figure directory not found: $FIGURE_DIR"
    exit 1
fi

echo "Converting images in $FIGURE_DIR to JPG format (max size: ${MAX_SIZE_KB} kB)..."
echo ""

# Process each image file
find "$FIGURE_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.tif" \) | while read -r image_file; do
    # Skip .gitkeep and other non-image files
    if [[ "$(basename "$image_file")" == .* ]]; then
        continue
    fi

    filename=$(basename "$image_file")
    name_without_ext="${filename%.*}"
    dir=$(dirname "$image_file")
    output_file="${dir}/${name_without_ext}.jpg"

    # Skip if already JPG and small enough
    if [[ "$filename" =~ \.(jpg|jpeg)$ ]]; then
        current_size=$(stat -f%z "$image_file" 2>/dev/null || stat -c%s "$image_file" 2>/dev/null)
        if [ "$current_size" -le "$MAX_SIZE_BYTES" ]; then
            echo "Skipping $filename (already JPG and <= ${MAX_SIZE_KB} kB)"
            continue
        fi
    fi

    echo "Processing: $filename"

    # Use temporary file if output is same as input (for JPG files)
    if [ "$image_file" = "$output_file" ]; then
        temp_file="${output_file}.tmp"
        use_temp=true
    else
        temp_file="$output_file"
        use_temp=false
    fi

    # Start with quality 85 and adjust if needed
    quality=85
    min_quality=30
    step=5

    # Try to compress the image
    while [ $quality -ge $min_quality ]; do
        # Convert to JPG with specified quality
        if [ "$CONVERT_CMD" = "magick" ]; then
            $CONVERT_CMD "$image_file" -quality "$quality" -strip "$temp_file" 2>/dev/null
        else
            $CONVERT_CMD "$image_file" -quality "$quality" -strip "$temp_file" 2>/dev/null
        fi

        # Check file size
        if [ -f "$temp_file" ]; then
            file_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)

            if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
                echo "  ✓ Converted to ${name_without_ext}.jpg (${file_size} bytes, quality: $quality)"

                # If original file was not JPG, remove it
                if [[ ! "$filename" =~ \.(jpg|jpeg)$ ]]; then
                    rm "$image_file"
                    echo "  ✓ Removed original file: $filename"
                fi

                # Move temp file to final location
                if [ "$use_temp" = true ]; then
                    mv "$temp_file" "$output_file"
                fi
                break
            else
                # File is still too large, reduce quality
                quality=$((quality - step))
                if [ $quality -lt $min_quality ]; then
                    # If quality reduction isn't enough, try resizing
                    echo "  Warning: Quality reduction not enough, attempting resize..."

                    # Get image dimensions
                    if [ "$CONVERT_CMD" = "magick" ]; then
                        dimensions=$($CONVERT_CMD identify -format "%wx%h" "$image_file" 2>/dev/null)
                    else
                        dimensions=$(identify -format "%wx%h" "$image_file" 2>/dev/null)
                    fi

                    width=$(echo "$dimensions" | cut -d'x' -f1)
                    height=$(echo "$dimensions" | cut -d'x' -f2)

                    # Try reducing dimensions by 10% increments
                    scale=90
                    while [ $scale -ge 50 ]; do
                        new_width=$((width * scale / 100))
                        new_height=$((height * scale / 100))

                        if [ "$CONVERT_CMD" = "magick" ]; then
                            $CONVERT_CMD "$image_file" -resize "${new_width}x${new_height}" -quality "$min_quality" -strip "$temp_file" 2>/dev/null
                        else
                            $CONVERT_CMD "$image_file" -resize "${new_width}x${new_height}" -quality "$min_quality" -strip "$temp_file" 2>/dev/null
                        fi

                        if [ -f "$temp_file" ]; then
                            file_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)

                            if [ "$file_size" -le "$MAX_SIZE_BYTES" ]; then
                                echo "  ✓ Converted to ${name_without_ext}.jpg (${file_size} bytes, resized to ${scale}%, quality: $min_quality)"

                                # Remove original if not JPG
                                if [[ ! "$filename" =~ \.(jpg|jpeg)$ ]]; then
                                    rm "$image_file"
                                    echo "  ✓ Removed original file: $filename"
                                fi

                                # Move temp file to final location
                                if [ "$use_temp" = true ]; then
                                    mv "$temp_file" "$output_file"
                                fi
                                break 2
                            fi
                        fi

                        scale=$((scale - 10))
                    done

                    # If still too large, keep the smallest version we could create
                    if [ -f "$temp_file" ]; then
                        file_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)
                        echo "  ⚠ Converted to ${name_without_ext}.jpg (${file_size} bytes) - still larger than ${MAX_SIZE_KB} kB"

                        if [[ ! "$filename" =~ \.(jpg|jpeg)$ ]]; then
                            rm "$image_file"
                            echo "  ✓ Removed original file: $filename"
                        fi

                        # Move temp file to final location
                        if [ "$use_temp" = true ]; then
                            mv "$temp_file" "$output_file"
                        fi
                    else
                        echo "  ✗ Failed to convert $filename"
                    fi
                    break
                fi
            fi
        else
            echo "  ✗ Failed to convert $filename"
            break
        fi
    done
done

echo ""
echo "Conversion complete!"
