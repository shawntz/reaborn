# Change how single-letter color codes are interpreted

Port of `seaborn.set_color_codes`. Returns (invisibly) the mapping from
the single-letter codes `b g r m y c k` to the colors of the given
seaborn palette, so reaborn helpers can resolve them like seaborn does.

## Usage

``` r
set_color_codes(palette = "deep")
```

## Arguments

- palette:

  One of `"deep"`, `"muted"`, `"pastel"`, `"bright"`, `"dark"`,
  `"colorblind"`.

## Value

Invisibly, the named character vector of code -\> hex mappings.
