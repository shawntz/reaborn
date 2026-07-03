# A continuous reaborn colormap

Constructed internally by palette functions when `as_cmap = TRUE`. It
wraps a 256-row RGB lookup table and is a function mapping values in
`[0, 1]` to hex colors via matplotlib's floor-index quantization. The
hex LUT is stored in `attr(., "colors")`.

## Usage

``` r
rb_make_cmap(lut256, name = "reaborn")
```
