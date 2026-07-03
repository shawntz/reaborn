# Draw an enhanced box plot for larger datasets

Port of `seaborn.boxenplot` (letter-value plot). Returns a
[reaborn_plot](https://reaborn.org/dev/reference/reaborn_plot.md).

## Usage

``` r
boxenplot(
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
  width = 0.8,
  gap = 0,
  linewidth = NULL,
  linecolor = NULL,
  width_method = "exponential",
  k_depth = "tukey",
  outlier_prop = 0.007,
  trust_alpha = 0.05,
  showfliers = TRUE,
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

- width, gap:

  Box width and gap between dodged boxes.

- linewidth:

  Box outline width.

- linecolor:

  Box outline color.

- width_method:

  `"exponential"`, `"linear"`, or `"area"`.

- k_depth:

  `"tukey"`, `"proportion"`, `"trustworthy"`, `"full"`, or an int.

- outlier_prop, trust_alpha:

  Tail-rule parameters.

- showfliers:

  Draw outlier points.

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
boxenplot(data = tips, x = "day", y = "total_bill")

boxenplot(data = tips, x = "day", y = "total_bill", hue = "smoker")
```
