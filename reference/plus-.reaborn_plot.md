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
