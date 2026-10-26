# pdf-tools

Small command-line helpers for turning scans and PDFs into something searchable and editable.

| Tool | Input | Output |
|---|---|---|
| [`jpg2pdf-ocr/`](jpg2pdf-ocr/) | a `.zip` of JPG page scans | one compressed, searchable `<name>_ocr.pdf` |
| [`pdf2md/`](pdf2md/) | a PDF with a text layer | `<name>_md/` holding the Markdown plus extracted images |

They chain: OCR a scanned zip with `jpg2pdf-ocr`, then feed the resulting PDF to `pdf2md`.

## Get it on a new machine

```bash
git clone https://github.com/nairaalamvt/pdf-tools.git
cd pdf-tools
```

To pick up later changes, run `git pull`.

## Quick start

**jpg2pdf-ocr**

- Linux / WSL: `./jpg2pdf-ocr/jpg2pdf_ocr.sh scans.zip`
- macOS: `./jpg2pdf-ocr/jpg2pdf_ocr_mac.sh scans.zip`, or double-click `jpg2pdf_ocr.command`
- Windows: drag the zip onto `jpg2pdf_ocr.bat`. It runs the `.sh` through WSL.

**pdf2md**

- macOS / Linux / WSL: `./pdf2md/pdf2md.sh paper.pdf`
- Windows: drag the PDF onto `pdf2md.bat`.

Each folder's `README.txt` has the one-time dependency install (apt / Homebrew / pip) and troubleshooting notes.
