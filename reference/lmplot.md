# Figure-level interface for regression plots

Port of `seaborn.lmplot`. Draws
[regplot](https://reaborn.org/reference/regplot.md) across a grid of
facets and/or hue groups. Returns a
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md).

## Usage

``` r
lmplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  col = NULL,
  row = NULL,
  palette = NULL,
  col_wrap = NULL,
  height = 5,
  aspect = 1,
  order = 1,
  logistic = FALSE,
  lowess = FALSE,
  robust = FALSE,
  logx = FALSE,
  ci = 95,
  n_boot = 1000,
  seed = NULL,
  scatter = TRUE,
  fit_reg = TRUE,
  hue_order = NULL,
  row_order = NULL,
  col_order = NULL,
  legend = TRUE,
  facet_kws = NULL,
  ...
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Variables.

- hue, col, row:

  Semantic / faceting variables.

- palette:

  Hue palette.

- col_wrap, row_order, col_order, hue_order:

  Ordering / wrapping.

- height, aspect:

  Facet sizing.

- order:

  Polynomial order for the fit (default 1, linear).

- logistic, lowess, robust, logx:

  Alternative fits.

- ci:

  Confidence-band width (default 95; `NULL` to omit).

- n_boot, seed:

  Bootstrap settings.

- scatter, fit_reg:

  Whether to draw the scatter / the fit.

- legend, facet_kws:

  Legend / facet options.

- ...:

  Reserved.

## Value

A `reaborn_plot`.
