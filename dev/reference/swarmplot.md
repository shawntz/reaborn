# Draw a categorical scatter with non-overlapping points

Port of `seaborn.swarmplot`, using a beeswarm layout. Returns a
[reaborn_plot](https://reaborn.org/dev/reference/reaborn_plot.md).

## Usage

``` r
swarmplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  order = NULL,
  hue_order = NULL,
  dodge = FALSE,
  orient = NULL,
  color = NULL,
  palette = NULL,
  size = 5,
  edgecolor = NULL,
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

  Passed to
  [ggbeeswarm::geom_beeswarm](https://rdrr.io/pkg/ggbeeswarm/man/geom_beeswarm.html).

## Value

A `reaborn_plot`.

## Examples

``` r
tips <- load_dataset("tips")
swarmplot(data = tips, x = "day", y = "total_bill")

swarmplot(data = tips, x = "day", y = "total_bill", hue = "sex", dodge = TRUE)
```
