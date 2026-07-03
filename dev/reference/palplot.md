# Plot the values in a color palette as a horizontal array

Port of `seaborn.palplot`. Returns a
[reaborn_plot](https://reaborn.org/dev/reference/reaborn_plot.md).

## Usage

``` r
palplot(pal, size = 1)
```

## Arguments

- pal:

  A sequence of colors (e.g. from
  [color_palette](https://reaborn.org/dev/reference/color_palette.md)).

- size:

  Scaling factor for the swatch size.

## Value

A `reaborn_plot`.

## Examples

``` r
palplot(color_palette("deep"))

palplot(color_palette("rocket", 8))
```
