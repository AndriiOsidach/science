# NULP Science Practice Works

LaTeX repository for Science Practice Works (Науково-дослідна практика) at National University "Lviv Polytechnic" (NULP), with Docker-based builds.

## Repository structure

- `pws/<id>/` — practical works (PWS) reports (e.g. `pws/1/main.tex`).
- `docs/` — templates and guideline documents (e.g. `title.docx`).
- `styles/` — common LaTeX styles and packages (`main.sty`).
- `scripts/` — helper scripts for title page generation and image processing.

## Quick start

1. **Build the image**:

   ```bash
   docker compose build
   ```

2. **Compile practice works**:

   ```bash
   docker compose run --rm bachelor-diploma-thesis-template make all
   ```

   PDFs are written to `build/pdfs/` (e.g. `build/pdfs/pws-1.pdf`).

   You can also build a specific practical work by its ID:

   ```bash
   docker compose run --rm bachelor-diploma-thesis-template make pws-1
   ```

3. **Clean up**:

   ```bash
   docker compose run --rm bachelor-diploma-thesis-template make clean
   ```

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

## Compress images

**Reduce the size of images**:

```bash
docker compose run --rm bachelor-diploma-thesis-template make compress
```

_The script processes PNG, JPEG, GIF, BMP, and TIFF files. Non-JPEG sources are replaced with `.jpg` files; update `\includegraphics{...}` paths in your `.tex` files if extensions change._
