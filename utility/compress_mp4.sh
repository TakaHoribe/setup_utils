#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_path> <compression_rate (e.g. 0.1 = 10%)>"
    exit 1
fi

# Get the arguments
file_path=$1
compression_rate=$2

# Extract directory, filename without extension, and extension
dir=$(dirname "$file_path")
filename=$(basename -- "$file_path")
extension="${filename##*.}"
filename="${filename%.*}"

# Generate output file name
output_file="${dir}/${filename}_compressed.${extension}"

# Run ffmpeg command with width and height divisible by 2
ffmpeg -i "$file_path" -vf "scale=trunc(iw*$compression_rate/2)*2:trunc(ih*$compression_rate/2)*2" -c:a copy "$output_file"

echo "Compressed video saved as $output_file"
