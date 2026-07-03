# Plot an empirical cumulative distribution function

Port of `seaborn.ecdfplot`. Returns a
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md).

## Usage

``` r
ecdfplot(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  weights = NULL,
  stat = "proportion",
  complementary = FALSE,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
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

  `"proportion"`, `"count"`, or `"percent"`.

- complementary:

  Plot the complementary ECDF (1 - F).

- palette:

  Palette for the hue mapping.

- hue_order:

  Order of hue levels.

- hue_norm:

  Normalization for a numeric hue.

- legend:

  Show the legend.

- .facet_vars:

  Internal; facet columns forwarded by the figure-level dispatchers
  (catplot/displot/relplot). Not intended for direct use.

- ...:

  Passed to the bar geom.

## Value

A `reaborn_plot`.

## Examples

``` r
penguins <- load_dataset("penguins")
ecdfplot(data = penguins, x = "flipper_length_mm", hue = "species")


# Complementary ECDF with counts
ecdfplot(data = penguins, x = "bill_length_mm", stat = "count", complementary = TRUE)
```
