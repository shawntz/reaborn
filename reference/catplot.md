# Figure-level interface for categorical plots

Port of `seaborn.catplot`. Dispatches to
[stripplot](https://reaborn.org/reference/stripplot.md)
(`kind = "strip"`), [boxplot](https://reaborn.org/reference/boxplot.md),
[barplot](https://reaborn.org/reference/barplot.md),
[pointplot](https://reaborn.org/reference/pointplot.md), or
[countplot](https://reaborn.org/reference/countplot.md) and adds row/col
faceting. Returns a faceted
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md).

## Usage

``` r
catplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  row = NULL,
  col = NULL,
  kind = "strip",
  estimator = "mean",
  errorbar = list("ci", 95),
  n_boot = 1000,
  seed = NULL,
  units = NULL,
  weights = NULL,
  order = NULL,
  hue_order = NULL,
  row_order = NULL,
  col_order = NULL,
  col_wrap = NULL,
  height = 5,
  aspect = 1,
  orient = NULL,
  color = NULL,
  palette = NULL,
  legend = "auto",
  facet_kws = NULL,
  ...
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Variables; the categorical one defines the groups.

- hue:

  Grouping variable for color (dodged).

- row, col, col_wrap, row_order, col_order:

  Faceting controls.

- kind:

  One of `"strip"`, `"box"`, `"bar"`, `"point"`, `"count"`.

- estimator, errorbar, n_boot, seed:

  Aggregation settings (bar/point).

- units:

  Unit grouping for bootstrap (bar/point kinds).

- weights:

  Observation weights (bar/point kinds).

- order, hue_order:

  Level orderings.

- height, aspect:

  Facet sizing (stored as attributes).

- orient:

  `"v"`, `"h"`, or `NULL` to infer.

- color:

  Single color override.

- palette:

  Palette for the hue mapping.

- legend:

  Legend control.

- facet_kws:

  Reserved for compatibility.

- ...:

  Passed to the underlying plotter.

## Value

A `reaborn_plot`.
