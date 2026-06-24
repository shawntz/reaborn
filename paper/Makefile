# Build the reaborn software paper.
#   make figures   regenerate figures from the installed reaborn package
#   make pdf        compile the LaTeX manuscript -> paper.pdf
#   make clean      remove LaTeX build artifacts

.PHONY: all figures pdf clean

all: pdf

figures:
	Rscript make-figures.R

pdf: paper.tex references.bib
	Rscript -e 'tinytex::latexmk("paper.tex")'

clean:
	rm -f paper.aux paper.bbl paper.blg paper.log paper.out paper.fdb_latexmk paper.fls
