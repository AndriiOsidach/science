# Bachelor diploma thesis template

LaTeX template for a bachelor qualification thesis, with Docker-based builds.

## Quick start

1. **Build the image**:

   ```bash
   docker compose build
   ```

2. **Compile the thesis**:

   ```bash
   docker compose run --rm bachelor-diploma-thesis-template make all
   ```

   PDFs are written to `build/pdfs/` (main output: `build/main.pdf`).

3. **Clean up**:

   ```bash
   docker compose run --rm bachelor-diploma-thesis-template make clean
   ```

## Compress images

**Reduce the size of the images in the `figure/` directory**:

```bash
docker compose run --rm bachelor-diploma-thesis-template make compress
```
_The script processes PNG, JPEG, GIF, BMP, and TIFF files under `figure/`. Non-JPEG sources are replaced with `.jpg` files; update `\includegraphics{...}` paths in your `.tex` files if extensions change._

## Generate title page

Generate a customized title page PDF (`pws/<id>/docs/title.pdf`) for practical work (PWS) from the template (`docs/title.docx`):

```bash
./scripts/generate_title.py <pws_id>
```

Example for practical work #1:

```bash
./scripts/generate_title.py 1
```

### Options

- `--input <path>`: Path to input template docx (default: `docs/title.docx`).
- `--outdir <path>`: Custom output directory (default: `pws/<pws_id>/docs`).
- `--name <string>`: Student full name (default: `Осідач Андрій Богданович`).
- `--group <string>`: Group code (default: `КНСШ-11`).

_Note: Requires LibreOffice (`libreoffice` CLI) to convert the modified document to PDF._
