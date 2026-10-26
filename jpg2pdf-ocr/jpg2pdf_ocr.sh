#!/usr/bin/env bash
# jpg2pdf_ocr.sh - merges JPGs from a zip into a single searchable, compressed
# OCR'd PDF. Cleans up the extracted images and the uncompressed intermediate
# PDF afterward, keeping only the final result, and prints a size comparison.
#
# Usage: ./jpg2pdf_ocr.sh /path/to/file.zip
set -e

# --- check required tools are actually installed first, with a helpful message ---
for tool in unzip img2pdf ocrmypdf; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Missing required tool: $tool"
        echo "Install everything needed with:"
        echo "  sudo apt update && sudo apt install -y --fix-missing unzip img2pdf ocrmypdf tesseract-ocr ghostscript jbig2 libjbig2enc0t64 unpaper pngquant"
        exit 1
    fi
done

ZIP="$1"
if [ -z "$ZIP" ]; then
    echo "Usage: $0 <path-to-zip>"
    exit 1
fi
if [ ! -f "$ZIP" ]; then
    echo "File not found: $ZIP"
    exit 1
fi

# human-readable size helper (falls back to raw bytes if numfmt is missing)
human() {
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec-i --suffix=B --format="%.1f" "$1"
    else
        echo "${1} bytes"
    fi
}

DIR="$(cd "$(dirname "$ZIP")" && pwd)"
BASE="$(basename "$ZIP" .zip)"
OUTDIR="${DIR}/${BASE}_extracted"
FINAL_PDF="${BASE}_ocr.pdf"

ZIP_SIZE=$(stat -c%s "$ZIP")

echo "=== Extracting ==="
mkdir -p "$OUTDIR"
unzip -o "$ZIP" -d "$OUTDIR"
cd "$OUTDIR"

echo
echo "=== Finding images ==="
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | sort -V > filelist.txt
COUNT=$(wc -l < filelist.txt)
echo "Found $COUNT image file(s)"
if [ "$COUNT" -eq 0 ]; then
    echo "No .jpg/.jpeg files found inside the zip - aborting."
    rm -f filelist.txt
    exit 1
fi
echo "First few, in the order they'll be merged:"
head -5 filelist.txt

echo
echo "=== Merging into PDF ==="
img2pdf $(cat filelist.txt) -o merged.pdf
MERGED_SIZE=$(stat -c%s merged.pdf)

echo
echo "=== OCR + compressing ==="
ocrmypdf --optimize 3 --deskew --clean merged.pdf "$FINAL_PDF"
FINAL_SIZE=$(stat -c%s "$FINAL_PDF")

echo
echo "=== Cleaning up ==="
# delete the extracted jpg/jpeg files themselves
rm -f $(cat filelist.txt)
rm -f filelist.txt
# delete the uncompressed intermediate PDF
rm -f merged.pdf
# tidy up any now-empty subfolders left over from the zip's internal structure
find . -mindepth 1 -type d -empty -delete 2>/dev/null || true
echo "Removed extracted images and uncompressed intermediate PDF."

echo
echo "=== Size comparison ==="
printf "%-22s %12s\n" "Original zip:"    "$(human "$ZIP_SIZE")"
printf "%-22s %12s\n" "Full-size PDF was:" "$(human "$MERGED_SIZE")"
printf "%-22s %12s\n" "Final OCR PDF:"    "$(human "$FINAL_SIZE")"
echo
awk -v z="$ZIP_SIZE" -v m="$MERGED_SIZE" -v f="$FINAL_SIZE" 'BEGIN {
    printf "Full PDF vs zip:    %+.1f%%\n", ((m - z) / z) * 100
    printf "Final PDF vs full:  %+.1f%%\n", ((f - m) / m) * 100
    printf "Final PDF vs zip:   %+.1f%%\n", ((f - z) / z) * 100
}'

echo
echo "Done. Final file:"
echo "  $OUTDIR/$FINAL_PDF"
