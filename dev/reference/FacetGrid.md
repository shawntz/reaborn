# A faceted grid of plots

Lightweight port of `seaborn.FacetGrid`. In reaborn, faceting is usually
done by adding `+ ggplot2::facet_wrap()`/`facet_grid()` to a plot, or
via the figure-level functions
([relplot](https://reaborn.org/dev/reference/relplot.md),
[displot](https://reaborn.org/dev/reference/displot.md),
[catplot](https://reaborn.org/dev/reference/catplot.md),
[lmplot](https://reaborn.org/dev/reference/lmplot.md)). This constructor
returns a base plot you can map geoms onto.

## Usage

``` r
FacetGrid(
  data,
  row = NULL,
  col = NULL,
  hue = NULL,
  col_wrap = NULL,
  height = 3,
  aspect = 1,
  palette = NULL
)
```

## Arguments

- data:

  A data frame.

- row, col, hue:

  Faceting / hue variables.

- col_wrap:

  Wrap columns at this width.

- height, aspect:

  Facet sizing.

- palette:

  Hue palette.

## Value

A `reaborn_plot`.

## Examples

``` r
tips <- load_dataset("tips")
FacetGrid(tips, col = "time", hue = "sex") +
  ggplot2::geom_point(ggplot2::aes(x = total_bill, y = tip))

FacetGrid(tips, row = "sex", col = "time") +
  ggplot2::geom_point(ggplot2::aes(x = total_bill, y = tip))
```
