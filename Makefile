LATEXINDENT_ARGS=-w -l -s -c build -m -r
LATEXMK_ARGS=-halt-on-error -time -xelatex -outdir=build -shell-escape
PDF_OUTPUT_DIR=build/pdfs

all: build

build: init
	latexmk $(LATEXMK_ARGS) src/main.tex
	$(MAKE) pdfs

pdfs:
	@mkdir -p $(PDF_OUTPUT_DIR)
	@chmod 777 $(PDF_OUTPUT_DIR) || true
	@find build/ -maxdepth 1 -name "*.pdf" -exec cp {} $(PDF_OUTPUT_DIR) \;
	@find $(PDF_OUTPUT_DIR) -maxdepth 1 -name "*.pdf" -exec chmod 666 {} \;
	@echo "All PDFs copied to $(PDF_OUTPUT_DIR)"

init:
	mkdir -p build
	chmod 777 build || true

format: | build
	git -c safe.directory="$$(pwd)" ls-files '*.tex' | xargs -r -n1 latexindent $(LATEXINDENT_ARGS)

compress:
	./scripts/compress_images.sh

clean:
	rm -rf build

.PHONY: all clean compress format pdfs build
