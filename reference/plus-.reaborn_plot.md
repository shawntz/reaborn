# Add to a reaborn plot, preserving its class

Ensures `reaborn_plot + <ggplot component>` stays a `reaborn_plot` so
the composed object keeps printing through reaborn and remains
chainable.

## Usage

``` r
# S3 method for class 'reaborn_plot'
e1 + e2
```

## Arguments

- e1:

  A reaborn plot.

- e2:

  A ggplot component (geom, scale, theme, facet, ...).

## Value

A reaborn plot.

## Details

Categorical plots collapse their data (via `rb_cat_setup()`, and for
bar/point/count an estimator aggregation), so the facet variable is
absent from the plotted data. When such a plot carries a re-aggregation
hook and the user adds a facet, we rebuild it with the facet columns
forwarded through setup + aggregation (the same `.facet_vars` path
[`catplot()`](https://reaborn.org/reference/catplot.md) uses) and then
apply the user's facet – so each panel shows, and for aggregating kinds
re-estimates, its own subset instead of one shared full-data summary
(#73).
