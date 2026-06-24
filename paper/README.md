# reaborn software paper

This directory holds the manuscript describing **reaborn**, kept in LaTeX so it is
easy to version-control, edit, and typeset, with a JOSS-format Markdown companion
generated from the same content and bibliography.

## Files

| File | Purpose |
|---|---|
| `paper.tex` | **Canonical manuscript** (LaTeX). Drives the preprint (arXiv) and the *R Journal* / *SoftwareX* submissions. |
| `paper.md` | **JOSS submission** (Markdown + YAML front-matter). JOSS compiles this with Open Journals; it does **not** accept arbitrary LaTeX. |
| `references.bib` | Shared BibTeX bibliography (used by both `paper.tex` and `paper.md`). |
| `make-figures.R` | Regenerates the figures from the installed `reaborn` package. |
| `figures/` | Rendered figures: `fig-relplot` (the seaborn fmri example reproduced in reaborn) and `fig-grammar` (the grammar-of-graphics composition). PDF for LaTeX, PNG for JOSS. |

One source of truth: both papers cite the same `references.bib`, and the same
figures are emitted in PDF (for LaTeX) and PNG (for JOSS) by `make-figures.R`.

## Build

```sh
# 1. Regenerate figures from the installed package
Rscript make-figures.R

# 2. Compile the LaTeX manuscript -> paper.pdf
latexmk -pdf paper.tex          # or: make pdf

# 3. (optional) preview the JOSS paper locally with the Open Journals/Inara
#    Docker container, or just lint the Markdown.
```

A `Makefile` is provided with `make figures`, `make pdf`, and `make clean`.

## Publication strategy

The aim is a **citable object as fast as possible** plus a peer-reviewed home.

1. **Immediate citable DOIs (do first):**
   - **Zenodo software DOI** — enable the GitHub–Zenodo integration and push a
     `v1.0.0` git tag to mint versioned + concept DOIs. Add the DOI to the paper's
     *Availability* section and to `CITATION.cff`.
   - **arXiv preprint** (suggested categories: `cs.GR` primary, `stat.CO`
     cross-list) compiled from `paper.tex`.
2. **Primary peer-reviewed venue: JOSS.** reaborn clears JOSS's current gates
   (multi-year public history, CRAN-grade packaging, CI, tests, documentation), and
   a re-implementation that cites prior work is explicitly in scope. Submit
   `paper.md`.
3. **Backup / alternative:** *The R Journal* (native R audience, LaTeX) or
   *SoftwareX* (indexed, LaTeX template, APC). Do **not** submit a near-identical
   paper to a journal and JOSS simultaneously.

## Before submitting (checklist)

- [ ] Confirm the author **affiliation** in `paper.tex` and `paper.md` (currently a
      placeholder).
- [ ] Mint the **Zenodo DOI** and replace the archive placeholder in both papers.
- [ ] Finalize the **AI usage disclosure** to match the actual development process
      (JOSS requires this section to be specific).
- [ ] Add **`CONTRIBUTING.md`**, **`CODE_OF_CONDUCT.md`**, and **`CITATION.cff`** to
      the repository root (JOSS review checklist).
- [ ] Verify the exact test count and tested **ggplot2 version** before quoting them.
