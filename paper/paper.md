---
title: 'reaborn: A faithful R port of seaborn built on the grammar of graphics'
tags:
  - R
  - data visualization
  - ggplot2
  - seaborn
  - statistical graphics
  - grammar of graphics
  - reproducibility
authors:
  - name: Shawn T. Schwartz
    orcid: 0000-0001-6444-8451
    corresponding: true
    affiliation: 1
affiliations:
  - name: "Department of Psychology, Stanford University, United States" # TODO: confirm/replace affiliation
    index: 1
date: 24 June 2026
bibliography: references.bib
---

# Summary

`reaborn` is an R package that ports the public application programming interface
(API) of the Python library seaborn [@waskom2021seaborn] onto ggplot2
[@wickham2016ggplot2], the dominant grammar-of-graphics engine for R. It mirrors
seaborn's roughly forty plotting functions — their names, argument names, and
default values — so that a chart specification written for seaborn produces a
visually equivalent figure in R. Attaching the package with `library(reaborn)`
installs seaborn's theme and color palette globally (as `sns.set_theme()` does in
Python), exposes `sns.`-prefixed aliases for every function, and binds the Python
literals `True`, `False`, and `None`; consequently, a call such as
`sns.scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm",
hue = "species")` runs verbatim in R. Crucially, every `reaborn` function returns
an ordinary ggplot2 object, so the resulting figure can be refined with the full
grammar of graphics — `+ facet_wrap()`, `+ scale_x_log10()`, `+ theme()`, or any
other layer — using vocabulary that ggplot2 users already know.

# Statement of need

Data visualization is integral to the scientific process, serving both to help a
researcher understand their own data and to communicate findings to others. The R
ecosystem provides this capability primarily through ggplot2, an implementation of
the layered grammar of graphics [@wickham2010layered] that formalizes Wilkinson's
*Grammar of Graphics* [@wilkinson2005grammar]. The grammar is expressive but
deliberately low-level: producing a polished exploratory figure typically requires
several layers and a block of theme and scale code, which many analysts copy into
the top of every notebook or project as boilerplate.

In the Python ecosystem, seaborn addresses this friction with opinionated,
named functions that infer sensible defaults — semantic color/size/style mappings,
statistical transformations with bootstrap confidence intervals, faceting, and a
coordinated visual theme — from a single call [@waskom2021seaborn]. No native R
package reproduces this interface. Analysts who know seaborn and move to R must
re-learn a different idiom, and ggplot2 users who want seaborn's defaults must
reconstruct them by hand. The only way to obtain *actual* seaborn output in R is
through reticulate [@reticulate], which requires a Python and seaborn installation
and returns static matplotlib raster images rather than composable ggplot2 objects.
`reaborn` removes this friction: it gives seaborn users a zero-translation landing
in R and gives ggplot2 users seaborn-grade scaffolding that remains fully
manipulable with the grammar they already use.

# State of the field

Because ggplot2 is a low-level grammar, a rich ecosystem of higher-level helpers
has grown around it to supply opinionated defaults and reduce boilerplate: ggpubr
wraps ggplot2 into publication-ready calls with statistical annotations
[@ggpubr], GGally adds pairs and correlation matrices via `ggpairs` [@ggally],
ggdist and the easystats `see` package add distribution and model-visualization
geoms [@kay2024ggdist; @ludecke2021see], cowplot and patchwork compose multi-panel
figures [@wilke2024cowplot; @patchwork], and lattice offers an alternative
trellis system [@sarkar2008lattice]. Each of these is built on, and returns,
ggplot2 (or grid) objects, but none reproduces seaborn's public API — its named
functions, argument names, defaults, and specific statistics.

This distinction matters because the seaborn paper frames seaborn as categorically
separate from the grammar of graphics. Waskom [@waskom2021seaborn] states that
seaborn "does not implement the formal Grammar of Graphics and cannot be used to
produce arbitrary visualizations," instead offering rapid exploration through
opinionated named functions while deferring deeper customization to matplotlib.
`reaborn` dissolves this dichotomy in R: it delivers seaborn's named-function
defaults *and*, because every plot is a ggplot2 object, the full grammar of
graphics in one library. The closest precedent runs in the opposite direction —
plotnine, a port of ggplot2 to Python [@kibirige2025plotnine]; `reaborn` is the
symmetric and, to our knowledge, first faithful seaborn-API port to R that returns
native grammar-composable objects.

# Software design

`reaborn` is not a thin wrapper. Its plotting functions funnel through a shared
data-assignment engine that resolves long- and wide-form input [@wickham2014tidy]
and a semantic-mapping layer that translates seaborn's `hue`/`size`/`style`
arguments into ggplot2 scales. To make figures genuinely indistinguishable from
seaborn rather than merely similar, the package reproduces seaborn's underlying
numerics: kernel density estimates match `scipy.stats.gaussian_kde`
[@virtanen2020scipy] to machine precision; histogram bins reproduce
`numpy.histogram_bin_edges` [@harris2020numpy] exactly; error bars use seaborn's
bootstrap confidence intervals rather than ggplot2's analytic standard errors; and
the color palettes, including matplotlib's colormap quantization and named-color
table [@hunter2007matplotlib], are matched to identical hexadecimal codes. Custom
statistics that ggplot2 does not ship — the kernel-density violin, the
letter-value (boxen) plot, and the beeswarm layout — are implemented directly, and
multi-panel grids (`pairplot`, `jointplot`) are assembled with patchwork
[@patchwork]. Each design choice reflects an explicit trade-off between fidelity
to seaborn and idiomatic R; where the two conflict, `reaborn` preserves the
behavior a seaborn user would expect while keeping the return value a standard
ggplot2 object.

![The fmri `relplot` example from the seaborn documentation, reproduced in `reaborn` with the identical call `relplot(data = fmri, x = "timepoint", y = "signal", hue = "event", style = "event", col = "region", kind = "line")`. The style mapping (dashed line), bootstrap confidence bands, faceting, and theme are reproduced natively in R.\label{fig:relplot}](figures/fig-relplot.png){ width=98% }

![A `reaborn` one-liner returns a ggplot2 object, so native grammar-of-graphics layers compose directly onto it. Here a `scatterplot()` call is extended with ggplot2's `stat_ellipse()` and `facet_wrap(~island)` — composition that seaborn's matplotlib-`Axes` return value does not support.\label{fig:grammar}](figures/fig-grammar.png){ width=98% }

# Research impact

`reaborn` lowers the barrier to reproducible, publication-quality graphics for two
large communities: researchers migrating analyses between Python and R, and the
broad base of R users who rely on ggplot2. Its significance is supported by a
runnable fidelity suite that verifies, against the reference implementations,
that palettes, kernel density estimates, histogram bin edges, and bootstrap
intervals match seaborn — a reproducible benchmark of cross-language equivalence
rather than an aspirational claim. The package is feature-complete across
seaborn's relational, distributional, categorical, regression, matrix, and
multi-panel families; is documented with a full website and worked examples at
<https://reaborn.org>; and is engineered to community standards (continuous
integration across platforms, a clean `R CMD check`, and an extensive automated
test suite). By making seaborn's vocabulary available natively in R while
returning grammar-composable objects, `reaborn` is positioned to be adopted in
day-to-day exploratory analysis and to be cited as the tool used to produce
figures.

# AI usage disclosure

<!-- TODO (author): review and finalize this disclosure to match your actual process before submission. -->
Generative AI coding assistants were used to assist with portions of the
implementation, test scaffolding, documentation, and the drafting of this
manuscript. All AI-generated output was reviewed, edited, and validated by the
author; the core architectural and design decisions were made by the author, and
all statistical-fidelity claims were verified against the seaborn, SciPy, and
NumPy reference implementations.

# Acknowledgements

We thank the developers of seaborn, ggplot2, and the broader matplotlib and
tidyverse ecosystems, upon whose work `reaborn` builds.

# References
