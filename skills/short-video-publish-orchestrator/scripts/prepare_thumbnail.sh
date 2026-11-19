#!/usr/bin/env bash
# Make a YouTube-ready thumbnail: same pixel size, JPEG, under 2 MB.
#
# Why: YouTube rejects custom thumbnails over 2 MB, and designed PNG covers are often 3–4 MB.
# Converting to JPEG keeps the picture identical (no resize, no crop) and shrinks the file.
#
# Usage: prepare_thumbnail.sh INPUT_IMAGE [OUTPUT_DIR]
#   OUTPUT_DIR defaults to .tmp/thumbs. Keep it inside your project folder, because
#   the browser tool may only upload files from folders it's allowed to read.
#
# Prints the output path on success.
# Uses `sips` on macOS, otherwise ImageMagick (`magick` or `convert`), otherwise Python Pillow.

set -euo pipefail

IN="${1:-}"
OUT_DIR="${2:-.tmp/thumbs}"
LIMIT=$((2 * 1024 * 1024))

if [[ -z "$IN" || ! -f "$IN" ]]; then
    echo "Usage: $0 INPUT_IMAGE [OUTPUT_DIR]" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"
BASE="$(basename "${IN%.*}")"
OUT="$OUT_DIR/$BASE.jpg"

file_size() { stat -f%z "$1" 2>/dev/null || stat -c%s "$1"; }

convert_at() {  # $1 = JPEG quality
    local q="$1"
    if command -v sips >/dev/null 2>&1; then
        sips -s format jpeg -s formatOptions "$q" "$IN" --out "$OUT" >/dev/null
    elif command -v magick >/dev/null 2>&1; then
        magick "$IN" -quality "$q" "$OUT"
    elif command -v convert >/dev/null 2>&1; then
        convert "$IN" -quality "$q" "$OUT"
    else
        python3 - "$IN" "$OUT" "$q" <<'PY'
import sys
from PIL import Image
src, dst, q = sys.argv[1], sys.argv[2], int(sys.argv[3])
Image.open(src).convert("RGB").save(dst, "JPEG", quality=q)
PY
    fi
}

for q in 92 85 78 70 60; do
    convert_at "$q"
    if (( $(file_size "$OUT") < LIMIT )); then
        echo "$OUT"
        exit 0
    fi
done

echo "Could not get $IN under 2 MB even at quality 60. Resize it (e.g. to 1080×1920) and retry." >&2
exit 3
