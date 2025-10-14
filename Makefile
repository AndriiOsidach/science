LATEXINDENT_ARGS=-w -l -s -c build -m -r
LATEXMK_ARGS=-halt-on-error -time -xelatex -outdir=build -shell-escape
PDF_OUTPUT_DIR=build/pdfs

all: build

build: init
	latexmk $(LATEXMK_ARGS) src/main.tex
	$(MAKE) pdfs

pdfs:
	@mkdir -p $(PDF_OUTPUT_DIR)
	@find build/ -maxdepth 1 -name "*.pdf" -exec cp {} $(PDF_OUTPUT_DIR) \;
	@echo "All PDFs copied to $(PDF_OUTPUT_DIR)"

init:
	mkdir -p build

format: | build
	git ls-files | grep .tex$ | xargs -n1 latexindent $(LATEXINDENT_ARGS)

clean:
	rm -rf build

.PHONY: all clean format pdfs build
