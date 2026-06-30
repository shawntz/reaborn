# seaborn-style `sns.` function aliases

For copy-paste compatibility with Python, reaborn provides a
`sns.`-prefixed alias for every public plotting, palette, and theming
function (R allows dots in identifiers). So pasted seaborn code such as
`sns.scatterplot(data = df, x = "a", y = "b", hue = "g")` runs verbatim.
Each alias is identical to its unprefixed counterpart; see that function
for arguments and details.

## Value

Each `sns.`-prefixed object is the exact same function as its unprefixed
counterpart (`sns.scatterplot <- scatterplot`, and so on), so calling an
alias returns precisely what the counterpart returns. By category: the
plotting functions (e.g. `sns.scatterplot()`, `sns.histplot()`,
`sns.heatmap()`, `sns.pairplot()`, `sns.FacetGrid()`, `sns.palplot()`)
return a `reaborn_plot` object (a ggplot2/patchwork object that draws
when printed), except the easter-egg `sns.dogplot()`, which prints an
affirmation and returns `NULL` invisibly; the palette constructors (e.g.
`sns.color_palette()`, `sns.husl_palette()`, `sns.cubehelix_palette()`)
return a character vector of hex colors, or a `reaborn_cmap`; the color
helpers `sns.desaturate()`, `sns.saturate()`, and `sns.set_hls_values()`
return a hex color string; `sns.axes_style()` and
`sns.plotting_context()` return a named list of style/context
parameters; `sns.despine()` and `sns.move_legend()` return a ggplot2
theme object to add to a plot; `sns.load_dataset()` returns a data frame
and `sns.get_dataset_names()` a character vector; and the theming
setters (`sns.set_theme()`, `sns.set()`, `sns.set_style()`,
`sns.set_context()`, `sns.set_palette()`, `sns.set_color_codes()`,
`sns.reset_defaults()`, `sns.reset_orig()`) are called for their side
effect of changing global plot defaults and return their value
invisibly. See each unprefixed function's own help page for the precise
structure and meaning of its return value.

## Examples

``` r
pen <- load_dataset("penguins")
p <- sns.scatterplot(data = pen, x = "bill_length_mm", y = "bill_depth_mm",
                     hue = "species")
```
