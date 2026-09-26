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
