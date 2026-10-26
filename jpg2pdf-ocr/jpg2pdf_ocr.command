#!/usr/bin/env bash
# jpg2pdf_ocr.command - double-click this in Finder, then drag your zip
# into the Terminal window when prompted.
#
# macOS has no drag-onto-a-file equivalent of the Windows .bat trick, so
# this prompts instead. Keep it next to jpg2pdf_ocr_mac.sh.

cd "$(dirname "$0")"

SH="./jpg2pdf_ocr_mac.sh"
if [ ! -f "$SH" ]; then
    echo "Could not find jpg2pdf_ocr_mac.sh next to this file."
    echo "Both must live in the SAME folder."
    echo
    read -r -p "Press Return to close..." _
    exit 1
fi

echo "============================================"
echo " JPG zip  ->  searchable OCR PDF"
echo "============================================"
echo
echo "Drag your .zip file into this window, then press Return."
echo
read -r -p "Zip file: " ZIPPATH

# strip the quoting/escaping Terminal adds when you drag a file in
ZIPPATH="${ZIPPATH%\"}"
ZIPPATH="${ZIPPATH#\"}"
ZIPPATH="${ZIPPATH%\'}"
ZIPPATH="${ZIPPATH#\'}"
ZIPPATH="$(printf '%s' "$ZIPPATH" | sed 's/\\ / /g')"

if [ -z "$ZIPPATH" ]; then
    echo "No file given."
    echo
    read -r -p "Press Return to close..." _
    exit 1
fi

echo
bash "$SH" "$ZIPPATH"

echo
read -r -p "Press Return to close..." _
