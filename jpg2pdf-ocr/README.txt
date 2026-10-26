JPG-in-a-zip -> single searchable, compressed OCR PDF
=========================================================

SETUP (one time)
-----------------
Put both jpg2pdf_ocr.bat and jpg2pdf_ocr.sh in the SAME folder. They
depend on being right next to one another.

Install the WSL tools (only needs doing once):
  wsl
  sudo apt update
  sudo apt install -y --fix-missing unzip img2pdf ocrmypdf tesseract-ocr ghostscript jbig2 libjbig2enc0t64 unpaper pngquant

USAGE
-----------------
Drag and drop your .zip file directly onto jpg2pdf_ocr.bat in File
Explorer. A command window opens and runs the whole pipeline.

(Or from cmd: jpg2pdf_ocr.bat "D:\path\to\your.zip")

Linux / WSL directly:
  ./jpg2pdf_ocr.sh /path/to/your.zip

WHAT IT DOES
-----------------
1. Extracts the zip into a "<zipname>_extracted" folder next to it
2. Finds every .jpg/.jpeg inside (any subfolder), sorted in natural
   page order
3. Merges them into a PDF
4. Runs OCR, deskewing, and heavy image optimization on it
5. Deletes the extracted jpg files and the uncompressed intermediate
   PDF, keeping ONLY the final "<zipname>_ocr.pdf"
6. Prints a size comparison: original zip, what the uncompressed PDF
   would have been, and the final OCR'd PDF's actual size

Everything except the final "<zipname>_ocr.pdf" is cleaned up
automatically - the extracted images and the uncompressed PDF are
both deleted once the OCR'd version exists.

TROUBLESHOOTING
-----------------
"Missing required tool: ..." - run the apt install command from SETUP
above. If it fails partway with a 400 error from the mirror, just run
the same command again - that's usually a transient glitch, not a
real problem.

"Could not convert the zip path via wslpath" - means WSL itself isn't
responding; try running `wsl` on its own first to confirm it launches.

If ocrmypdf itself complains about a missing program (unpaper,
pngquant, etc.), install just that one package and rerun - the SETUP
command above already covers every dependency this script currently
needs, but ocrmypdf's own optional features occasionally require
something new after an update.

NOTE ON FLAGS
-----------------
--jbig2-lossy was deliberately removed: it is deprecated and silently
ignored in current ocrmypdf, dropped upstream over risks of character
substitution errors in the OCR'd text layer.


=========================================================
MACOS
=========================================================

Use jpg2pdf_ocr_mac.sh instead of the .sh/.bat pair. The
Windows .bat is WSL-specific and does nothing on a Mac.

SETUP (one time)
-----------------
Install Homebrew if you don't have it:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then:
  brew install ocrmypdf img2pdf tesseract ghostscript jbig2enc unpaper pngquant coreutils

coreutils is optional but recommended - it supplies gsort and
gnumfmt. Without it the script falls back to slower/rougher
built-ins, which still work.

Make the scripts executable once (not needed if you cloned with git):
  chmod +x jpg2pdf_ocr_mac.sh jpg2pdf_ocr.command

USAGE
-----------------
Terminal:
  ./jpg2pdf_ocr_mac.sh /path/to/your.zip
(you can drag the zip from Finder into Terminal to paste its path)

Or double-click jpg2pdf_ocr.command in Finder and drag the zip
into the window when prompted.

macOS may block the .command the first time with an "unidentified
developer" warning. Right-click it -> Open -> Open, or run:
  xattr -d com.apple.quarantine jpg2pdf_ocr.command

WHAT DIFFERS FROM THE WINDOWS VERSION
-----------------
- stat -c%s (GNU) replaced with a BSD/GNU-detecting helper
- sort -V does not exist in BSD sort; uses gsort when available
  so page2 still sorts before page10
- numfmt is GNU-only; falls back to awk formatting
- strips __MACOSX folders and ._ resource-fork stubs, which
  macOS-created zips carry and which would otherwise be merged
  in as blank pages
