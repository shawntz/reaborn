# Draw a categorical scatter with jitter

Port of `seaborn.stripplot`. Returns a
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md).

## Usage

``` r
stripplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  order = NULL,
  hue_order = NULL,
  jitter = TRUE,
  dodge = FALSE,
  orient = NULL,
  color = NULL,
  palette = NULL,
  size = 5,
  edgecolor = "gray",
  linewidth = 0,
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

- jitter:

  `TRUE`, `FALSE`, or a numeric jitter amount.

- dodge:

  Separate hue levels along the categorical axis.

- orient:

  `"v"`, `"h"`, or `NULL` to infer.

- color:

  Single color override.

- palette:

  Palette for the hue mapping.

- size:

  Marker size (seaborn default 5).

- edgecolor, linewidth:

  Marker edge styling.

- legend:

  Legend control.

- .facet_vars:

  Internal; facet columns forwarded by the figure-level dispatchers
  (catplot/displot/relplot). Not intended for direct use.

- ...:

  Passed to the point geom.

## Value

A `reaborn_plot`.
