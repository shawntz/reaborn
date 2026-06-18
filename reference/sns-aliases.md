# seaborn-style `sns.` function aliases

For copy-paste compatibility with Python, reaborn provides a
`sns.`-prefixed alias for every public plotting, palette, and theming
function (R allows dots in identifiers). So pasted seaborn code such as
`sns.scatterplot(data = df, x = "a", y = "b", hue = "g")` runs verbatim.
Each alias is identical to its unprefixed counterpart; see that function
for arguments and details.

## Examples

``` r
pen <- load_dataset("penguins")
p <- sns.scatterplot(data = pen, x = "bill_length_mm", y = "bill_depth_mm",
                     hue = "species")
```
