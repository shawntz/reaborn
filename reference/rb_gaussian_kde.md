# Univariate Gaussian KDE matching scipy.stats.gaussian_kde

Univariate Gaussian KDE matching scipy.stats.gaussian_kde

## Usage

``` r
rb_gaussian_kde(
  x,
  bw_method = "scott",
  bw_adjust = 1,
  gridsize = 200,
  cut = 3,
  clip = NULL,
  weights = NULL,
  cumulative = FALSE
)
```

## Arguments

- x:

  Numeric data.

- bw_method:

  `"scott"` (default), `"silverman"`, or a numeric factor.

- bw_adjust:

  Multiplicative bandwidth adjustment (seaborn `bw_adjust`).

- gridsize:

  Number of evaluation points (seaborn default 200).

- cut:

  Extend the grid `cut` bandwidths past the data extremes (default 3).

- clip:

  Length-2 numeric clip for the grid, or `NULL`.

- weights:

  Optional observation weights.

- cumulative:

  Return the cumulative distribution instead of the density.

## Value

A list with `x` (grid) and `y` (density) vectors.
