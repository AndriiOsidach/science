# Agent Guidelines

## Docker Compose Execution

All build, compilation, formatting, and script commands must be run inside Docker via Docker Compose using the `bachelor-diploma-thesis-template` service. Do not run LaTeX, ImageMagick, or build tools directly on the host.

### General Syntax

```bash
docker compose run --rm bachelor-diploma-thesis-template <command>
```

### Common Commands

- **Build/rebuild the Docker image**:
  ```bash
  docker compose build
  ```

- **Compile all practice works**:
  ```bash
  docker compose run --rm bachelor-diploma-thesis-template make all
  ```

- **Compile a specific practical work (e.g., PWS 1, PWS 2)**:
  ```bash
  docker compose run --rm bachelor-diploma-thesis-template make pws-<id>
  ```
  *(Compiled PDFs are placed in `build/pdfs/pws-<id>.pdf`)*

- **Format LaTeX source files**:
  ```bash
  docker compose run --rm bachelor-diploma-thesis-template make format
  ```

- **Clean build artifacts**:
  ```bash
  docker compose run --rm bachelor-diploma-thesis-template make clean
  ```

## Image Compression Rule

- **ALWAYS run the compress script for images** whenever adding or updating figures/images in the repository. Uncompressed images must never be committed.

### Compression Commands

- Run compression via Make (defaults to figure directory configured in script):
  ```bash
  docker compose run --rm bachelor-diploma-thesis-template make compress
  ```

- Run compression on a specific directory:
  ```bash
  docker compose run --rm bachelor-diploma-thesis-template ./scripts/compress_images.sh pws/<id>/figures
  ```

### Note on Image Formats

The script converts non-JPEG images (PNG, GIF, BMP, TIFF) to `.jpg` and replaces the source files. Ensure `\includegraphics{...}` statements in `.tex` files point to the `.jpg` filename or omit the file extension.
