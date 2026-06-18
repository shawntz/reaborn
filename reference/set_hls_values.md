# Independently set the hue, lightness, and/or saturation of a color

Port of `seaborn.set_hls_values`.

## Usage

``` r
set_hls_values(color, h = NULL, l = NULL, s = NULL)
```

## Arguments

- color:

  A matplotlib-compatible color.

- h, l, s:

  New hue, lightness, saturation in `[0, 1]`, or `NULL` to keep.

## Value

A hex color string.
