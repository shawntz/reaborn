# Draw a scatter plot with semantic mappings

Port of `seaborn.scatterplot`. Returns a
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md) (a
ggplot), so it can be extended with any ggplot2 component.

## Usage

``` r
scatterplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  size = NULL,
  style = NULL,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
  sizes = NULL,
  size_order = NULL,
  size_norm = NULL,
  markers = TRUE,
  style_order = NULL,
  legend = "auto",
  ...
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Column names (strings) or vectors giving the axes.

- hue, size, style:

  Column names/vectors for color, size, and marker-style semantics.

- palette, hue_order, hue_norm:

  Control the color mapping.

- sizes, size_order, size_norm:

  Control the size mapping.

- markers, style_order:

  Control the style (marker) mapping.

- legend:

  `"auto"`, `"brief"`, `"full"`, or `FALSE`.

- ...:

  Passed to
  [ggplot2::geom_point](https://ggplot2.tidyverse.org/reference/geom_point.html).

## Value

A `reaborn_plot`.
