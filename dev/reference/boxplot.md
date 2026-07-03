# Draw a box plot

Port of `seaborn.boxplot`. Returns a
[reaborn_plot](https://reaborn.org/dev/reference/reaborn_plot.md).

## Usage

``` r
boxplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  order = NULL,
  hue_order = NULL,
  orient = NULL,
  color = NULL,
  palette = NULL,
  saturation = 0.75,
  fill = TRUE,
  dodge = "auto",
  width = 0.8,
  gap = 0,
  whis = 1.5,
  linecolor = "auto",
  linewidth = NULL,
  fliersize = NULL,
  legend = "auto",
  .facet_vars = NULL,
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

- order, hue_order:

  Level orderings.

- orient:

  `"v"`, `"h"`, or `NULL` to infer.

- color, palette, saturation, fill:

  Color controls (saturation default 0.75).

- dodge:

  How to dodge boxes by hue (`"auto"`, `TRUE`, or `FALSE`).

- width, gap:

  Box width and gap between dodged boxes.

- whis:

  Whisker length in IQR units (default 1.5).

- linecolor, linewidth, fliersize:

  Line and outlier styling.

- legend:

  Legend control.

- .facet_vars:

  Internal; facet columns forwarded by the figure-level dispatchers
  (catplot/displot/relplot). Not intended for direct use.

- ...:

  Passed to
  [ggplot2::geom_boxplot](https://ggplot2.tidyverse.org/reference/geom_boxplot.html).

## Value

A `reaborn_plot`.

## Examples

``` r
tips <- load_dataset("tips")
boxplot(data = tips, x = "day", y = "total_bill")

boxplot(data = tips, x = "day", y = "total_bill", hue = "smoker")
```
