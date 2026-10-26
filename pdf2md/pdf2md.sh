#!/usr/bin/env bash
# pdf2md - convert a PDF to Markdown, extracting embedded images
# into an images/ subfolder linked inline.
#
# Usage: ./pdf2md.sh /path/to/file.pdf
set -e

PYTHON="${PDF2MD_PYTHON:-python3}"

if ! "$PYTHON" -c "import pymupdf4llm" >/dev/null 2>&1; then
    echo "Missing required Python package: pymupdf4llm"
    echo "Install it with:"
    echo "  pip install 'pymupdf4llm<2' --break-system-packages"
    echo "(on macOS with Homebrew python, --break-system-packages is needed too,"
    echo " or use a venv: python3 -m venv ~/.venvs/pdf2md && source ~/.venvs/pdf2md/bin/activate && pip install 'pymupdf4llm<2')"
    exit 1
fi

PDF="$1"
if [ -z "$PDF" ]; then
    echo "Usage: $0 <path-to-pdf>"
    exit 1
fi
if [ ! -f "$PDF" ]; then
    echo "File not found: $PDF"
    exit 1
fi

DIR="$(cd "$(dirname "$PDF")" && pwd)"
BASE="$(basename "$PDF" .pdf)"
PDF_ABS="${DIR}/$(basename "$PDF")"
OUTDIR="${DIR}/${BASE}_md"

mkdir -p "$OUTDIR/images"
cd "$OUTDIR"

echo "=== Converting ==="
PDF_PATH="$PDF_ABS" MD_NAME="${BASE}.md" "$PYTHON" <<'PYEOF'
import os
import pymupdf4llm

md = pymupdf4llm.to_markdown(
    os.environ["PDF_PATH"],
    write_images=True,
    image_path="images",
    image_format="png",
)
with open(os.environ["MD_NAME"], "w", encoding="utf-8") as f:
    f.write(md)
PYEOF

IMG_COUNT=$(find images -type f | wc -l | tr -d ' ')

# remove the images folder entirely if nothing was actually extracted,
# so you don't end up with a pointless empty folder for text-only PDFs
if [ "$IMG_COUNT" -eq 0 ]; then
    rmdir images 2>/dev/null || true
fi

echo
echo "=== Done ==="
echo "Markdown file: $OUTDIR/${BASE}.md"
echo "Images extracted: $IMG_COUNT"
if [ "$IMG_COUNT" -gt 0 ]; then
    echo "Images folder: $OUTDIR/images/"
fi
