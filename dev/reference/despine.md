# Remove spines from a plot

Port of `seaborn.despine`. Returns a ggplot2 theme partial that removes
the requested plot borders and (for borderless styles) draws explicit
axis lines on the kept sides. Add it to a reaborn/ggplot plot:
`p + despine()`.

## Usage

``` r
despine(
  fig = NULL,
  ax = NULL,
  top = TRUE,
  right = TRUE,
  left = FALSE,
  bottom = FALSE,
  offset = NULL,
  trim = FALSE
)
```

## Arguments

- fig, ax:

  Ignored (kept for signature compatibility with seaborn).

- top, right, left, bottom:

  Logical; whether to remove that spine. Defaults match seaborn: remove
  top and right, keep left and bottom.

- offset, trim:

  Not supported by ggplot2; accepted but ignored in v1 with a one-time
  message. Present for signature compatibility.

## Value

A ggplot2 theme object to add to a plot.
