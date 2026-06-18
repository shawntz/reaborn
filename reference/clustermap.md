# Plot a hierarchically-clustered heatmap

Port of `seaborn.clustermap`. Reorders rows/columns by hierarchical
clustering and draws dendrograms alongside the heatmap. Returns a
patchwork composition.

## Usage

``` r
clustermap(
  data,
  method = "average",
  metric = "euclidean",
  z_score = NULL,
  standard_scale = NULL,
  row_cluster = TRUE,
  col_cluster = TRUE,
  cmap = NULL,
  dendrogram_ratio = 0.2,
  ...
)
```

## Arguments

- data:

  A matrix or data frame.

- method:

  Linkage method (default `"average"`).

- metric:

  Distance metric (default `"euclidean"`).

- z_score:

  Normalize rows (`0`) or columns (`1`) to z-scores.

- standard_scale:

  Scale rows (`0`) or columns (`1`) to `[0, 1]`.

- row_cluster, col_cluster:

  Whether to cluster rows / columns.

- cmap:

  Colormap (default `"rocket"`).

- dendrogram_ratio:

  Fraction of the figure used by the dendrograms.

- ...:

  Passed to [heatmap](https://reaborn.org/reference/heatmap.md).

## Value

A `reaborn_plot` (patchwork).
