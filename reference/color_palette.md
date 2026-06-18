# Return a list of colors or a continuous colormap defining a palette

Port of `seaborn.color_palette`. Possible `palette` values include the
name of a seaborn palette (`deep`, `muted`, `bright`, `pastel`, `dark`,
`colorblind`), a matplotlib colormap name, `"husl"`/`"hls"`, a cubehelix
shorthand (`"ch:..."`), `"light:<color>"`, `"dark:<color>"`,
`"blend:<c1>,<c2>"`, or a sequence of colors.

## Usage

``` r
color_palette(palette = NULL, n_colors = NULL, desat = NULL, as_cmap = FALSE)

hls_palette(n_colors = 6, h = 0.01, l = 0.6, s = 0.65, as_cmap = FALSE)

husl_palette(n_colors = 6, h = 0.01, s = 0.9, l = 0.65, as_cmap = FALSE)

dark_palette(
  color,
  n_colors = 6,
  reverse = FALSE,
  as_cmap = FALSE,
  input = "rgb"
)

light_palette(
  color,
  n_colors = 6,
  reverse = FALSE,
  as_cmap = FALSE,
  input = "rgb"
)

diverging_palette(
  h_neg,
  h_pos,
  s = 75,
  l = 50,
  sep = 1,
  n = 6,
  center = "light",
  as_cmap = FALSE
)

blend_palette(colors, n_colors = 6, as_cmap = FALSE, input = "rgb")

mpl_palette(name, n_colors = 6, as_cmap = FALSE)

cubehelix_palette(
  n_colors = 6,
  start = 0,
  rot = 0.4,
  gamma = 1,
  hue = 0.8,
  light = 0.85,
  dark = 0.15,
  reverse = FALSE,
  as_cmap = FALSE
)
```

## Arguments

- palette:

  `NULL`, a string, or a sequence of colors.

- n_colors:

  Number of colors. If `NULL`, depends on `palette`.

- desat:

  Proportion to desaturate each color by.

- as_cmap:

  If `TRUE`, return a continuous colormap (a `reaborn_cmap`).

- h, l, s:

  Hue, lightness, saturation anchors in `[0, 1]`.

- color:

  Base color for the high end of a sequential palette.

- reverse:

  Reverse the direction of the blend.

- input:

  Color space of the input color: `"rgb"`, `"hls"`, or `"husl"`.

- h_neg, h_pos:

  Anchor hues (`[0, 359]`) for the negative and positive ends.

- sep:

  Size of the intermediate (center) region.

- n:

  Number of colors (when not returning a cmap).

- center:

  `"light"` or `"dark"` center.

- colors:

  A sequence of colors to blend between.

- name:

  Name of a matplotlib colormap.

- start, rot, gamma, hue, light, dark:

  Cubehelix parameters (see seaborn).

## Value

A character vector of hex colors, or a `reaborn_cmap`.
