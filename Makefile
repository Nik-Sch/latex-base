drawio_src=$(shell find diagrams/ -type f -name "*.drawio.svg")
drawio_obj=$(drawio_src:diagrams/%.drawio.svg=diagrams/%.pdf)

plots_src=$(shell find plots/ -type f -name "*.py" -not -name "yolo.py")
plots_obj=$(plots_src:plots/%.py=plots/%.pdf)

paper_src=paper.tex
presentation_src=presentation.tex

tex_cmd=latexmk --shell-escape -pdf -g -halt-on-error

export TEXINPUTS=.:./tub-presentation:

withDocker:
	./docker.sh make watch

watch:
	while true; do \
			make all -j20; \
		inotifywait -qre close_write,delete --excludei ".git*|out*" .; \
	done

all: paper.pdf presentation.pdf

paper.pdf: $(bytefields_obj) $(drawio_obj) $(wavedrom_obj) $(seqdiag_obj) $(plots_obj) $(paper_src) bib.bib
	$(tex_cmd) paper
	cp out/paper.pdf .

presentation.pdf: $(bytefields_obj) $(drawio_obj) $(wavedrom_obj) $(seqdiag_obj) $(plots_obj) $(presentation_src) bib.bib
	echo $$TEXINPUTS
	$(tex_cmd) presentation
	cp out/presentation.pdf .

diagrams/%.pdf: diagrams/%.drawio.svg
	svg2pdf $< $@

.SECONDEXPANSION:
plots/%.pdf: plots/%.py $$(wildcard plots/$$*.log)
	python3 $< $@

clean:
	rm -rf $(bytefields_obj) $(drawio_obj) $(wavedrom_obj) $(seqdiag_obj) $(plots_obj) out tikz_out paper.pdf presentation.pdf

.PHONY: waitDocker watch all clean
