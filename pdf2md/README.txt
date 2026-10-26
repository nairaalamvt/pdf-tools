=========================================================
PDF -> MARKDOWN  (pdf2md)
=========================================================

Converts a PDF into a Markdown file with any embedded images
extracted into an images/ subfolder and linked inline.

FILES
-----------------
  pdf2md.sh    the converter (macOS / Linux / WSL)
  pdf2md.bat   Windows drag-and-drop wrapper (runs pdf2md.sh via WSL)
  README.txt   this file

SETUP (one time)
-----------------
  pip install "pymupdf4llm<2" --break-system-packages

macOS without pip: either
  brew install python
  pip3 install "pymupdf4llm<2"
or bootstrap Apple's Python:
  python3 -m ensurepip --upgrade

Or in a venv, which is tidier on macOS:
  python3 -m venv ~/.venvs/pdf2md
  source ~/.venvs/pdf2md/bin/activate
  pip install "pymupdf4llm<2"

To use the venv without activating it each time:
  export PDF2MD_PYTHON=~/.venvs/pdf2md/bin/python3
(put that line in ~/.zshrc or ~/.bashrc to make it permanent)

Then make the script executable:
  chmod +x pdf2md.sh

USAGE
-----------------
macOS / Linux / WSL:
  ./pdf2md.sh /path/to/your.pdf

Windows: drag a .pdf onto pdf2md.bat
  (keep pdf2md.bat and pdf2md.sh in the same folder)

OUTPUT
-----------------
Creates "<pdfname>_md/" next to the original PDF containing:
  <pdfname>.md         the Markdown
  images/              extracted PNGs, only if there were any

For a text-only PDF the empty images/ folder is removed
automatically rather than left behind.

NOTES
-----------------
The "<2" pin matters: pymupdf4llm 2.0 can install as an empty
package, after which the script reports it as missing. If that
happens, rerun the pin with --force-reinstall. Tested with 0.3.4.

pdf2md needs a PDF that already has a text layer. For scanned
pages, run an OCR pass first (e.g. ocrmypdf input.pdf output.pdf)
to add one, then feed the OCR'd PDF to pdf2md.

Paths with spaces, quotes or apostrophes are handled: the path
is passed to Python through an environment variable, not
interpolated into code.

The same script runs on macOS and Linux - it uses no
GNU-specific tools, so there is no separate _mac version.
