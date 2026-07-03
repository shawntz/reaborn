# Matplotlib-style axis breaks

Approximates matplotlib's `MaxNLocator` / `AutoLocator` (the default
axis tick locator), which places ticks at "nice" round numbers using the
step sequence 1, 2, 2.5, 5, 10. ggplot2's default
([`scales::extended_breaks`](https://scales.r-lib.org/reference/breaks_extended.html))
targets fewer ticks and lands on different values, so reaborn plots use
this to match seaborn's gridline density and tick positions.

## Usage

``` r
rb_mpl_breaks(n = 9)
```

## Arguments

- n:

  Target maximum number of intervals (matplotlib's default is ~9).

## Value

A function of `limits` returning a numeric vector of break positions,
suitable for the `breaks` argument of a ggplot2 continuous scale.
