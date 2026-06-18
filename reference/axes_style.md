# Get the parameters that control the general style of the plots

Port of `seaborn.axes_style`. Returns the resolved style definition.

## Usage

``` r
axes_style(style = NULL, rc = NULL)

set_style(style = NULL, rc = NULL)
```

## Arguments

- style:

  One of `"darkgrid"`, `"whitegrid"`, `"dark"`, `"white"`, `"ticks"`.

- rc:

  Optional named list of overrides.

## Value

A named list describing the style.
