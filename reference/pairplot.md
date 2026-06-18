# Plot pairwise relationships in a dataset

Port of `seaborn.pairplot`. Returns a patchwork matrix of scatter plots
with univariate distributions on the diagonal.

## Usage

``` r
pairplot(
  data,
  vars = NULL,
  hue = NULL,
  kind = "scatter",
  diag_kind = "auto",
  palette = NULL,
  height = 2.5,
  aspect = 1,
  corner = FALSE,
  ...
)
```

## Arguments

- data:

  A data frame.

- vars:

  Columns to include (default all numeric).

- hue:

  Grouping variable for color.

- kind:

  Off-diagonal kind: `"scatter"` or `"reg"`.

- diag_kind:

  Diagonal kind: `"auto"`, `"hist"`, or `"kde"`.

- palette, height, aspect, corner:

  Layout controls.

- ...:

  Reserved.

## Value

A `reaborn_plot` (patchwork).
