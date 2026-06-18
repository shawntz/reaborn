# Plot a univariate or bivariate histogram

Port of `seaborn.histplot`. Returns a
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md).

## Usage

``` r
histplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  weights = NULL,
  stat = "count",
  bins = "auto",
  binwidth = NULL,
  binrange = NULL,
  discrete = NULL,
  cumulative = FALSE,
  common_bins = TRUE,
  common_norm = TRUE,
  multiple = "layer",
  element = "bars",
  fill = TRUE,
  shrink = 1,
  kde = FALSE,
  kde_kws = NULL,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
  color = NULL,
  legend = TRUE,
  .facet_vars = NULL,
  ...
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Column name/vector for the histogram variable (use `y` for a
  horizontal histogram).

- hue:

  Grouping variable for color.

- weights:

  Optional observation weights.

- stat:

  One of `"count"`, `"frequency"`, `"density"`, `"probability"`,
  `"proportion"`, `"percent"`.

- bins, binwidth, binrange, discrete:

  Binning controls (see
  [rb_hist_bins](https://reaborn.org/reference/rb_hist_bins.md)).

- cumulative:

  Accumulate counts.

- common_bins, common_norm:

  Share bins/normalization across hue groups.

- multiple:

  `"layer"`, `"stack"`, `"fill"`, or `"dodge"`.

- element:

  `"bars"` or `"step"`.

- fill:

  Whether to fill the bars.

- shrink:

  Shrink bar widths by this factor.

- kde:

  Overlay a KDE curve.

- kde_kws:

  Arguments for the KDE (e.g. `bw_adjust`).

- palette, hue_order, hue_norm, color:

  Color controls.

- legend:

  Show the legend.

- .facet_vars:

  Internal; facet columns forwarded by the figure-level dispatchers
  (catplot/displot/relplot). Not intended for direct use.

- ...:

  Passed to the bar geom.

## Value

A `reaborn_plot`.
