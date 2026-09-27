LATEXINDENT_ARGS=-w -l -s -c build -m -r
LATEXMK_ARGS=-halt-on-error -time -xelatex -outdir=build -shell-escape
PDF_OUTPUT_DIR=build/pdfs

PWS_SRCS=$(sort $(wildcard pws/*/main.tex))
PWS_TARGETS=$(patsubst pws/%/main.tex,pws-%,$(PWS_SRCS))

all: build

build: init $(PWS_TARGETS)
	$(MAKE) pdfs

pws: build

pws-%: pws/%/main.tex | init
	latexmk $(LATEXMK_ARGS) -jobname=pws-$* $<

pws/%: pws-%
	@:

pdfs:
	@mkdir -p $(PDF_OUTPUT_DIR)
	@chmod 777 $(PDF_OUTPUT_DIR) || true
	@find build/ -maxdepth 1 -name "*.pdf" -exec cp {} $(PDF_OUTPUT_DIR) \;
	@find $(PDF_OUTPUT_DIR) -maxdepth 1 -name "*.pdf" -exec chmod 666 {} \;
	@chmod -R 777 build 2>/dev/null || true
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

.PHONY: all clean compress format pdfs build pws
