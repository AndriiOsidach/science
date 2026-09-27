#!/usr/bin/env python3
"""
Generate a title page PDF for a practice work report (PWS).
Modifies docs/title.docx and converts it to pws/<pws_id>/docs/title.pdf.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile


def generate_title(pws_id: str, input_path: str = "docs/title.docx", out_dir: str = None,
                   name: str = "Осідач Андрій Богданович", group: str = "КНСШ-11") -> str:
    # Resolve repository root
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    if not os.path.isabs(input_path):
        input_path = os.path.join(repo_root, input_path)
    
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Template document not found at: {input_path}")
    
    if out_dir is None:
        out_dir = os.path.join(repo_root, "pws", str(pws_id), "docs")
    elif not os.path.isabs(out_dir):
        out_dir = os.path.join(repo_root, out_dir)
        
    os.makedirs(out_dir, exist_ok=True)
    dest_pdf = os.path.join(out_dir, "title.pdf")

    with tempfile.TemporaryDirectory() as tmpdir:
        temp_docx = os.path.join(tmpdir, "title.docx")
        
        with zipfile.ZipFile(input_path, "r") as zin:
            with zipfile.ZipFile(temp_docx, "w", compression=zipfile.ZIP_DEFLATED) as zout:
                for item in zin.infolist():
                    data = zin.read(item.filename)
                    if item.filename == "word/document.xml":
                        xml_str = data.decode("utf-8")
                        # 1. Replace practice work number (two ?? near №, ensuring №<id> without space)
                        xml_str = re.sub(r"№\s+", "№", xml_str)
                        xml_str = re.sub(
                            r"(№</w:t></w:r>)\s*<w:r[^>]*>(?:<w:rPr>[\s\S]*?</w:rPr>)?<w:t[^>]*>\s+</w:t></w:r>",
                            r"\1",
                            xml_str,
                        )
                        xml_str = re.sub(r"(<w:t[^>]*>)\s*\?\?\s*(</w:t>)", rf"\g<1>{pws_id}\g<2>", xml_str)
                        # 2. Replace group (КНСШ-1? -> КНСШ-11)
                        xml_str = re.sub(r"(<w:t[^>]*>)\?(</w:t>)", r"\g<1>1\g<2>", xml_str)
                        # 3. Replace ПІБ with student name
                        xml_str = re.sub(r"(<w:t[^>]*>)ПІБ(</w:t>)", rf"\g<1>{name}\g<2>", xml_str)
                        # 4. Remove yellow highlights from placeholders
                        xml_str = re.sub(r'<w:highlight\s+w:val="yellow"\s*/>', '', xml_str)
                        data = xml_str.encode("utf-8")
                    zout.writestr(item, data)

        # Convert modified docx to pdf using libreoffice
        cmd = ["libreoffice", "--headless", "--convert-to", "pdf", "--outdir", tmpdir, temp_docx]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(f"LibreOffice conversion failed:\n{res.stderr}")

        temp_pdf = os.path.join(tmpdir, "title.pdf")
        if not os.path.exists(temp_pdf):
            raise FileNotFoundError(f"Expected converted PDF at {temp_pdf} was not found.")

        shutil.copy2(temp_pdf, dest_pdf)

    return dest_pdf


def main():
    parser = argparse.ArgumentParser(description="Generate title.pdf for practice work (PWS).")
    parser.add_argument("pws_id", help="Practice work number (e.g., 1)")
    parser.add_argument("--input", default="docs/title.docx", help="Path to input template docx (default: docs/title.docx)")
    parser.add_argument("--outdir", default=None, help="Output directory (default: pws/<pws_id>/docs)")
    parser.add_argument("--name", default="Осідач Андрій Богданович", help="Student full name")
    parser.add_argument("--group", default="КНСШ-11", help="Group identifier")

    args = parser.parse_args()

    try:
        pdf_path = generate_title(
            pws_id=args.pws_id,
            input_path=args.input,
            out_dir=args.outdir,
            name=args.name,
            group=args.group,
        )
        print(f"Title PDF generated successfully at: {pdf_path}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
