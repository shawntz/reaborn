# Set multiple theme parameters in one step

Port of `seaborn.set_theme` (and its alias `set`). Sets the global look
used by subsequent reaborn (and ggplot2) plots.

## Usage

``` r
set_theme(
  context = "notebook",
  style = "darkgrid",
  palette = "deep",
  font = "sans",
  font_scale = 1,
  color_codes = TRUE,
  rc = NULL
)

set(...)
```

## Arguments

- context, style, palette, font, font_scale, color_codes, rc:

  See seaborn.

- ...:

  Passed to set_theme.

## Value

Invisibly, the applied
[ggplot2::theme](https://ggplot2.tidyverse.org/reference/theme.html).
