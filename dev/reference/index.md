# Package index

## Relational plots

Visualize statistical relationships between numeric variables.

- [`scatterplot()`](https://reaborn.org/dev/reference/scatterplot.md) :
  Draw a scatter plot with semantic mappings
- [`lineplot()`](https://reaborn.org/dev/reference/lineplot.md) : Draw a
  line plot with aggregation and error bands
- [`relplot()`](https://reaborn.org/dev/reference/relplot.md) :
  Figure-level interface for relational plots

## Distribution plots

Visualize univariate and bivariate distributions.

- [`histplot()`](https://reaborn.org/dev/reference/histplot.md) : Plot a
  univariate or bivariate histogram
- [`kdeplot()`](https://reaborn.org/dev/reference/kdeplot.md) : Plot a
  univariate or bivariate kernel density estimate
- [`ecdfplot()`](https://reaborn.org/dev/reference/ecdfplot.md) : Plot
  an empirical cumulative distribution function
- [`rugplot()`](https://reaborn.org/dev/reference/rugplot.md) : Plot
  marginal rug ticks
- [`displot()`](https://reaborn.org/dev/reference/displot.md) :
  Figure-level interface for distribution plots

## Categorical plots

Visualize one numeric and one (or more) categorical variables.

- [`boxplot()`](https://reaborn.org/dev/reference/boxplot.md) : Draw a
  box plot
- [`violinplot()`](https://reaborn.org/dev/reference/violinplot.md) :
  Draw a violin plot
- [`boxenplot()`](https://reaborn.org/dev/reference/boxenplot.md) : Draw
  an enhanced box plot for larger datasets
- [`stripplot()`](https://reaborn.org/dev/reference/stripplot.md) : Draw
  a categorical scatter with jitter
- [`swarmplot()`](https://reaborn.org/dev/reference/swarmplot.md) : Draw
  a categorical scatter with non-overlapping points
- [`barplot()`](https://reaborn.org/dev/reference/barplot.md) : Show
  point estimates and errors as bars
- [`pointplot()`](https://reaborn.org/dev/reference/pointplot.md) : Show
  point estimates and errors with markers
- [`countplot()`](https://reaborn.org/dev/reference/countplot.md) : Show
  value counts as bars
- [`catplot()`](https://reaborn.org/dev/reference/catplot.md) :
  Figure-level interface for categorical plots

## Regression plots

Visualize linear and other model fits with bootstrap confidence bands.

- [`regplot()`](https://reaborn.org/dev/reference/regplot.md) : Plot
  data and a linear regression model fit
- [`residplot()`](https://reaborn.org/dev/reference/residplot.md) : Plot
  the residuals of a linear regression
- [`lmplot()`](https://reaborn.org/dev/reference/lmplot.md) :
  Figure-level interface for regression plots

## Matrix plots

Visualize matrices as color-encoded heatmaps and clustered maps.

- [`heatmap()`](https://reaborn.org/dev/reference/heatmap.md) : Plot
  rectangular data as a color-encoded matrix
- [`clustermap()`](https://reaborn.org/dev/reference/clustermap.md) :
  Plot a hierarchically-clustered heatmap

## Multi-plot grids

Compose grids of plots for pairwise and joint relationships.

- [`pairplot()`](https://reaborn.org/dev/reference/pairplot.md) : Plot
  pairwise relationships in a dataset
- [`jointplot()`](https://reaborn.org/dev/reference/jointplot.md) : Draw
  a bivariate plot with marginal distributions
- [`FacetGrid()`](https://reaborn.org/dev/reference/FacetGrid.md) : A
  faceted grid of plots

## Color palettes

Build and use seaborn’s color palettes (matched to the hex digit).

- [`color_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`hls_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`husl_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`dark_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`light_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`diverging_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`blend_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`mpl_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  [`cubehelix_palette()`](https://reaborn.org/dev/reference/color_palette.md)
  : Return a list of colors or a continuous colormap defining a palette
- [`set_color_codes()`](https://reaborn.org/dev/reference/set_color_codes.md)
  : Change how single-letter color codes are interpreted

## Themes & contexts

Control the seaborn look — styles, scaling contexts, and despining.

- [`set_theme()`](https://reaborn.org/dev/reference/set_theme.md)
  [`set()`](https://reaborn.org/dev/reference/set_theme.md) : Set
  multiple theme parameters in one step
- [`axes_style()`](https://reaborn.org/dev/reference/axes_style.md)
  [`set_style()`](https://reaborn.org/dev/reference/axes_style.md) : Get
  the parameters that control the general style of the plots
- [`plotting_context()`](https://reaborn.org/dev/reference/plotting_context.md)
  [`set_context()`](https://reaborn.org/dev/reference/plotting_context.md)
  : Get the parameters that control the scaling of plot elements
- [`theme_seaborn()`](https://reaborn.org/dev/reference/theme_seaborn.md)
  : Build a ggplot2 theme replicating a seaborn style + context
- [`despine()`](https://reaborn.org/dev/reference/despine.md) : Remove
  spines from a plot
- [`move_legend()`](https://reaborn.org/dev/reference/move_legend.md) :
  Reposition a plot's legend
- [`reset_defaults()`](https://reaborn.org/dev/reference/reset_defaults.md)
  [`reset_orig()`](https://reaborn.org/dev/reference/reset_defaults.md)
  : Restore matplotlib/ggplot2 defaults
- [`set_palette()`](https://reaborn.org/dev/reference/set_palette.md) :
  Set the matplotlib color cycle / ggplot default discrete palette

## Datasets & utilities

Load example datasets and manipulate colors.

- [`load_dataset()`](https://reaborn.org/dev/reference/load_dataset.md)
  [`get_dataset_names()`](https://reaborn.org/dev/reference/load_dataset.md)
  : Load an example dataset from the seaborn-data repository
- [`desaturate()`](https://reaborn.org/dev/reference/desaturate.md) :
  Decrease the saturation of a color
- [`saturate()`](https://reaborn.org/dev/reference/saturate.md) :
  Increase the saturation of a color to its maximum
- [`set_hls_values()`](https://reaborn.org/dev/reference/set_hls_values.md)
  : Independently set the hue, lightness, and/or saturation of a color
- [`palplot()`](https://reaborn.org/dev/reference/palplot.md) : Plot the
  values in a color palette as a horizontal array
- [`dogplot()`](https://reaborn.org/dev/reference/dogplot.md) : Who's a
  good boy?

## Python compatibility

Helpers that let pasted seaborn Python run unchanged.

- [`True`](https://reaborn.org/dev/reference/python-literals.md)
  [`False`](https://reaborn.org/dev/reference/python-literals.md)
  [`None`](https://reaborn.org/dev/reference/python-literals.md) :
  Python literal compatibility values

- [`sns-aliases`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.scatterplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.lineplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.relplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.histplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.kdeplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.ecdfplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.rugplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.displot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.boxplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.violinplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.boxenplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.stripplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.swarmplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.barplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.pointplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.countplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.catplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.regplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.residplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.lmplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.heatmap`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.clustermap`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.pairplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.jointplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.FacetGrid`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.palplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.dogplot`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.color_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.hls_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.husl_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.mpl_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.dark_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.light_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.diverging_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.blend_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.cubehelix_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set_color_codes`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set_theme`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.reset_defaults`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.reset_orig`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.axes_style`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set_style`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.plotting_context`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set_context`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set_palette`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.desaturate`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.saturate`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.set_hls_values`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.move_legend`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.despine`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.load_dataset`](https://reaborn.org/dev/reference/sns-aliases.md)
  [`sns.get_dataset_names`](https://reaborn.org/dev/reference/sns-aliases.md)
  :

  seaborn-style `sns.` function aliases
