#!/usr/bin/env bash
# jpg2pdf_ocr_mac.sh - merges JPGs from a zip into a single searchable,
# compressed OCR'd PDF. macOS version: handles BSD vs GNU differences in
# stat, sort and numfmt so it works with or without coreutils installed.
#
# Usage: ./jpg2pdf_ocr_mac.sh /path/to/file.zip
set -e

for tool in unzip img2pdf ocrmypdf; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Missing required tool: $tool"
        echo "Install everything needed with:"
        echo "  brew install ocrmypdf img2pdf tesseract ghostscript jbig2enc unpaper pngquant coreutils"
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

# --- portable helpers -------------------------------------------------
# BSD stat wants -f%z, GNU stat wants -c%s
fsize() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

# GNU sort has -V (natural/version order); BSD sort does not.
# Prefer gsort from coreutils, then GNU sort, then a numeric-field fallback
# that keeps page2 before page10.
natsort() {
    if command -v gsort >/dev/null 2>&1; then
        gsort -V
    elif sort -V </dev/null >/dev/null 2>&1; then
        sort -V
    else
        sort -t'0' -k1,1 | sort -n -k1.1
    fi
}

# numfmt is GNU-only; fall back to awk
human() {
    if command -v gnumfmt >/dev/null 2>&1; then
        gnumfmt --to=iec-i --suffix=B --format="%.1f" "$1"
    elif command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec-i --suffix=B --format="%.1f" "$1"
    else
        awk -v b="$1" 'BEGIN {
            split("B KiB MiB GiB TiB", u, " ")
            i = 1
            while (b >= 1024 && i < 5) { b /= 1024; i++ }
            printf "%.1f%s", b, u[i]
        }'
    fi
}
# ----------------------------------------------------------------------

DIR="$(cd "$(dirname "$ZIP")" && pwd)"
BASE="$(basename "$ZIP" .zip)"
OUTDIR="${DIR}/${BASE}_extracted"
FINAL_PDF="${BASE}_ocr.pdf"

ZIP_SIZE=$(fsize "$ZIP")

echo "=== Extracting ==="
mkdir -p "$OUTDIR"
unzip -o "$ZIP" -d "$OUTDIR"
cd "$OUTDIR"

# macOS zips often carry a __MACOSX resource-fork folder full of ._ stub
# files; those would otherwise be picked up as bogus pages.
rm -rf __MACOSX
find . -name "._*" -type f -delete 2>/dev/null || true

echo
echo "=== Finding images ==="
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | natsort > filelist.txt
COUNT=$(wc -l < filelist.txt | tr -d ' ')
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
MERGED_SIZE=$(fsize merged.pdf)

echo
echo "=== OCR + compressing ==="
ocrmypdf --optimize 3 --deskew --clean merged.pdf "$FINAL_PDF"
FINAL_SIZE=$(fsize "$FINAL_PDF")

echo
echo "=== Cleaning up ==="
rm -f $(cat filelist.txt)
rm -f filelist.txt
rm -f merged.pdf
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
