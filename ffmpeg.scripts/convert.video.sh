trap "exit 1" INT
find . -maxdepth 2 -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o -name "*.mov" \) | while read -r file; do
  out="./output_folder/${file#./}"
  mkdir -p "$(dirname "$out")"
  ffmpeg -nostdin -threads 2 -i "$file" -c:v libx265 -c:a aac -b:a 320k -crf 28 -preset medium "${out%.*}.mp4"
done

exit 1
