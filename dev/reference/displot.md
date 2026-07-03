# Figure-level interface for distribution plots

Port of `seaborn.displot`. Draws
[histplot](https://reaborn.org/dev/reference/histplot.md)
(`kind = "hist"`),
[kdeplot](https://reaborn.org/dev/reference/kdeplot.md)
(`kind = "kde"`), or
[ecdfplot](https://reaborn.org/dev/reference/ecdfplot.md)
(`kind = "ecdf"`) onto a grid of facets. Returns a faceted
[reaborn_plot](https://reaborn.org/dev/reference/reaborn_plot.md).

## Usage

``` r
displot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  row = NULL,
  col = NULL,
  weights = NULL,
  kind = "hist",
  rug = FALSE,
  rug_kws = NULL,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
  color = NULL,
  col_wrap = NULL,
  row_order = NULL,
  col_order = NULL,
  legend = TRUE,
  height = 5,
  aspect = 1,
  facet_kws = NULL,
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

- row, col, col_wrap, row_order, col_order:

  Faceting controls.

- weights:

  Optional observation weights.

- kind:

  `"hist"`, `"kde"`, or `"ecdf"`.

- rug:

  Add a marginal rug.

- rug_kws:

  Arguments forwarded to the rug layer when `rug = TRUE`.

- palette, hue_order, hue_norm, color:

  Color controls.

- legend:

  Show the legend.

- height, aspect:

  Facet size controls (stored as attributes).

- facet_kws:

  Reserved for compatibility.

- ...:

  Passed to the bar geom.

## Value

A `reaborn_plot`.

## Examples

``` r
penguins <- load_dataset("penguins")
displot(data = penguins, x = "flipper_length_mm", col = "species")

displot(
  data = penguins, x = "flipper_length_mm",
  hue = "species", col = "sex", kind = "kde"
)
```
