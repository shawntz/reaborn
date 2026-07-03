# Gallery

Every plot below is **rendered live by reaborn in R** from the
seaborn-style code shown above it. Where it helps, a side-by-side panel
shows the same plot in reaborn and in Python seaborn — they are designed
to be indistinguishable.

## Reaborn vs. seaborn, at a glance

![reaborn vs seaborn scatter](../reference/figures/compare-scatter.png)

![reaborn vs seaborn violin](../reference/figures/compare-violin.png)

## Relational

### scatterplot

``` r

scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm", hue = "species")
```

![](gallery_files/figure-html/unnamed-chunk-1-1.png)

``` r

scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm",
            hue = "species", size = "body_mass_g", style = "species")
```

![](gallery_files/figure-html/unnamed-chunk-2-1.png)

### lineplot

With per-group aggregation and a bootstrap confidence band — matching
seaborn.

``` r

lineplot(data = fmri, x = "timepoint", y = "signal", hue = "event")
```

![](gallery_files/figure-html/unnamed-chunk-3-1.png)

### relplot

A figure-level wrapper that facets across `col`/`row`.

``` r

relplot(data = fmri, x = "timepoint", y = "signal", hue = "event",
        col = "region", kind = "line")
```

![](gallery_files/figure-html/unnamed-chunk-4-1.png)

## Distributions

### histplot

``` r

histplot(data = penguins, x = "flipper_length_mm", hue = "species", multiple = "stack")
```

![](gallery_files/figure-html/unnamed-chunk-5-1.png)

### kdeplot

The KDE reproduces `scipy.stats.gaussian_kde` to machine precision.

``` r

kdeplot(data = penguins, x = "flipper_length_mm", hue = "species", fill = TRUE)
```

![](gallery_files/figure-html/unnamed-chunk-6-1.png)

### ecdfplot

``` r

ecdfplot(data = penguins, x = "bill_length_mm", hue = "species")
```

![](gallery_files/figure-html/unnamed-chunk-7-1.png)

### displot

``` r

displot(data = penguins, x = "flipper_length_mm", col = "species")
```

![](gallery_files/figure-html/unnamed-chunk-8-1.png)

## Categorical

### boxplot & violinplot

``` r

boxplot(data = tips, x = "day", y = "total_bill", hue = "smoker")
```

![](gallery_files/figure-html/unnamed-chunk-9-1.png)

``` r

violinplot(data = tips, x = "day", y = "total_bill")
```

![](gallery_files/figure-html/unnamed-chunk-10-1.png)

### boxenplot

A faithful letter-value plot for larger samples.

``` r

boxenplot(data = penguins, x = "species", y = "body_mass_g")
```

![](gallery_files/figure-html/unnamed-chunk-11-1.png)

### stripplot & swarmplot

``` r

stripplot(data = tips, x = "day", y = "total_bill", hue = "sex")
```

![](gallery_files/figure-html/unnamed-chunk-12-1.png)

``` r

swarmplot(data = tips, x = "day", y = "total_bill")
```

![](gallery_files/figure-html/unnamed-chunk-13-1.png)

### barplot & pointplot

Error bars are seaborn’s bootstrap CI, not an analytic standard error.

``` r

barplot(data = tips, x = "day", y = "total_bill")
```

![](gallery_files/figure-html/unnamed-chunk-14-1.png)

``` r

pointplot(data = tips, x = "day", y = "total_bill", hue = "sex")
```

![](gallery_files/figure-html/unnamed-chunk-15-1.png)

## Regression

### regplot

The confidence band is a bootstrap interval, like seaborn.

``` r

regplot(data = tips, x = "total_bill", y = "tip")
```

![](gallery_files/figure-html/unnamed-chunk-16-1.png)

### lmplot

``` r

lmplot(data = tips, x = "total_bill", y = "tip", col = "time", hue = "smoker")
```

![](gallery_files/figure-html/unnamed-chunk-17-1.png)

## Matrix

### heatmap

``` r

flights <- load_dataset("flights")
mat <- tapply(flights$passengers, list(flights$month, flights$year), function(x) x[1])
heatmap(mat, annot = TRUE, fmt = "d", linewidths = 0.5)
```

![](gallery_files/figure-html/unnamed-chunk-18-1.png)

### clustermap

``` r

clustermap(mat)
```

![](gallery_files/figure-html/unnamed-chunk-19-1.png)

## Multi-plot grids

### jointplot

``` r

jointplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm", hue = "species")
```

![](gallery_files/figure-html/unnamed-chunk-20-1.png)

### pairplot

``` r

pairplot(penguins, vars = c("bill_length_mm", "bill_depth_mm", "flipper_length_mm"),
         hue = "species")
```

![](gallery_files/figure-html/unnamed-chunk-21-1.png)

## Palettes & themes

reaborn ships seaborn’s palettes, matched to the hex digit, and its five
styles.

``` r

palplot(color_palette("deep"))
```

![](gallery_files/figure-html/unnamed-chunk-22-1.png)

``` r

palplot(color_palette("husl", 8))
```

![](gallery_files/figure-html/unnamed-chunk-23-1.png)

``` r

set_theme(style = "whitegrid")
scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm", hue = "species")
```

![](gallery_files/figure-html/unnamed-chunk-24-1.png)

``` r

set_theme()  # restore the default darkgrid
```
