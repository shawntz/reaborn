# Plot data and a linear regression model fit

Port of `seaborn.regplot`. The confidence band is a bootstrap interval,
like seaborn. Returns a
[reaborn_plot](https://reaborn.org/reference/reaborn_plot.md).

## Usage

``` r
regplot(
  data = NULL,
  x = NULL,
  y = NULL,
  order = 1,
  logistic = FALSE,
  lowess = FALSE,
  robust = FALSE,
  logx = FALSE,
  ci = 95,
  n_boot = 1000,
  seed = NULL,
  scatter = TRUE,
  fit_reg = TRUE,
  color = NULL,
  marker = "o",
  scatter_kws = NULL,
  line_kws = NULL,
  truncate = TRUE,
  x_jitter = NULL,
  y_jitter = NULL,
  ...
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Variables.

- order:

  Polynomial order for the fit (default 1, linear).

- logistic, lowess, robust, logx:

  Alternative fits.

- ci:

  Confidence-band width (default 95; `NULL` to omit).

- n_boot, seed:

  Bootstrap settings.

- scatter, fit_reg:

  Whether to draw the scatter / the fit.

- color:

  Color for points and line (default the first palette color).

- marker:

  Marker (accepted for compatibility).

- scatter_kws, line_kws:

  Lists of extra args for the point / line layers.

- truncate:

  Limit the regression line to the data range.

- x_jitter:

  Uniform jitter added to x for display only.

- y_jitter:

  Uniform jitter added to y for display only.

- ...:

  Reserved.

## Value

A `reaborn_plot`.
