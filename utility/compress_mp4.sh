#!/bin/bash

# Function to get user input with a default value
get_input() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# Function to recommend bitrate based on resolution
recommend_bitrate() {
    case $1 in
        HD)
            echo 2500
            ;;
        FHD)
            echo 5000
            ;;
        4K)
            echo 20000
            ;;
        *)
            echo 5000
            ;;
    esac
}

# Get the arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_path>"
    exit 1
fi

file_path=$1

# Extract directory, filename without extension, and extension
dir=$(dirname "$file_path")
filename=$(basename -- "$file_path")
extension="${filename##*.}"
filename="${filename%.*}"

# Generate output file name
output_file="${dir}/${filename}_compressed.${extension}"

# Get original bitrate
original_bitrate=$(ffmpeg -i "$file_path" 2>&1 | grep bitrate | grep -o '[0-9]* kb/s' | grep -o '[0-9]*')
if [ -z "$original_bitrate" ]; then
    echo "Could not determine the original bitrate."
    exit 1
fi
recommended_bitrate=$(recommend_bitrate "FHD")

# Get original frame rate
original_framerate=$(ffmpeg -i "$file_path" 2>&1 | grep -oP '(\d+(\.\d+)? fps)' | grep -oP '(\d+(\.\d+)?)')
recommended_framerate=24

# Get original resolution
original_resolution=$(ffmpeg -i "$file_path" 2>&1 | grep -oP '\d{3,4}x\d{3,4}' | head -1)
recommended_resolution="FHD (1920x1080)"

# Display original and recommended values
echo "Original bitrate: ${original_bitrate} kbps, Recommended: ${recommended_bitrate} kbps"
echo "Original framerate: ${original_framerate} fps, Recommended: ${recommended_framerate} fps"
echo "Original resolution: ${original_resolution}, Recommended: ${recommended_resolution}"

# Get user inputs
bitrate=$(get_input "Specify the target bitrate in kbps" $recommended_bitrate)
framerate=$(get_input "Specify the target framerate in fps" $recommended_framerate)

resolution_choice=$(get_input "Specify the target resolution (HD, FHD, 4K, Original)" "FHD")
case $resolution_choice in
    HD)
        scale="1280:720"
        ;;
    FHD)
        scale="1920:1080"
        ;;
    4K)
        scale="3840:2160"
        ;;
    Original)
        scale="trunc(iw/2)*2:trunc(ih/2)*2"
        ;;
    *)
        echo "Invalid resolution choice, using recommended resolution."
        scale="1920:1080"
        ;;
esac

echo "scale=$scale, framerate = $framerate, bitrate = $bitrate"

# Run ffmpeg command with user inputs
ffmpeg -i "$file_path" -vf "scale=$scale" -r "$framerate" -c:v libx265 -b:v "${bitrate}k" -an "$output_file"

echo "Compressed video saved as $output_file"
