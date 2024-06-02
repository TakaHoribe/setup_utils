#!/bin/bash

input_file="$1"

filename=$(basename -- "$input_file")
extension="${filename##*.}"
filename="${filename%.*}"

output_file="${filename}_converted.mp4"

# -vf mpdecimate,setpts=N/FRAME_RATE/TB: これにより、重複したフレームが削除されます。
# mpdecimate: 重複したフレームを削除するフィルターです。
# setpts=N/FRAME_RATE/TB: フレームのタイムスタンプを再設定するためのオプションです。
# -c:v libx264: ビデオコーデックとしてlibx264を使用します。
# -crf 23: 出力ビデオの品質を設定します。値が小さいほど品質が高くなります（デフォルトは23）。
# -preset slow: エンコードのプリセットを指定します。slowはより高品質のエンコードを提供しますが、処理速度は遅くなります。
# -c:a aac: オーディオコーデックとしてaacを使用します。

# ffmpeg -i "$input_file" -vf mpdecimate,setpts=N/FRAME_RATE/TB -c:v libx264 -crf 23 -preset slow -c:a aac -b:a 128k "$output_file"
ffmpeg -i "$input_file" -c:v libx264 -crf 23 -preset veryfast -c:a aac -b:a 128k "$output_file"

echo "Conversion complete: $output_file"