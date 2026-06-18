# Build a ggplot2 theme replicating a seaborn style + context

Build a ggplot2 theme replicating a seaborn style + context

## Usage

``` r
theme_seaborn(
  style = "darkgrid",
  context = "notebook",
  font_scale = 1,
  font = "sans"
)
```

## Arguments

- style:

  A seaborn style name (see
  [axes_style](https://reaborn.org/reference/axes_style.md)).

- context:

  A seaborn context name (see
  [plotting_context](https://reaborn.org/reference/plotting_context.md)).

- font_scale:

  Font scaling factor.

- font:

  Base font family.

## Value

A complete
[ggplot2::theme](https://ggplot2.tidyverse.org/reference/theme.html)
object.
