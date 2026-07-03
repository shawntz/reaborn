# Reposition a plot's legend

Port of `seaborn.move_legend`. Returns a theme partial controlling
legend position. Add it to a plot: `p + move_legend("upper right")`.

## Usage

``` r
move_legend(obj = NULL, loc = "best", ...)
```

## Arguments

- obj:

  Ignored (signature compatibility).

- loc:

  A seaborn/matplotlib location string (e.g. `"upper right"`,
  `"center left"`), `"best"`, or a length-2 numeric vector of relative
  coords.

- ...:

  Additional theme arguments (e.g. `title`).

## Value

A ggplot2 theme object to add to a plot.
