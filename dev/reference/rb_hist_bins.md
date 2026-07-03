# Histogram bin edges matching numpy.histogram_bin_edges

Histogram bin edges matching numpy.histogram_bin_edges

## Usage

``` r
rb_hist_bins(
  x,
  bins = "auto",
  binrange = NULL,
  binwidth = NULL,
  discrete = FALSE
)
```

## Arguments

- x:

  Numeric data.

- bins:

  A rule name (`"auto"`, `"fd"`, `"sturges"`, `"scott"`, `"rice"`,
  `"sqrt"`, `"doane"`), an integer bin count, or an explicit numeric
  vector of edges.

- binrange:

  Optional `c(min, max)` overriding the data extremes.

- binwidth:

  Optional explicit bin width (overrides `bins`).

- discrete:

  If `TRUE`, place bins on integer centers.

## Value

A numeric vector of bin edges.
