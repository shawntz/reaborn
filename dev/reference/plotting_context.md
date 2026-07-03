# Get the parameters that control the scaling of plot elements

Port of `seaborn.plotting_context`. Returns a named list of resolved
sizes.

## Usage

``` r
plotting_context(context = NULL, font_scale = 1, rc = NULL)

set_context(context = NULL, font_scale = 1, rc = NULL)
```

## Arguments

- context:

  One of `"paper"`, `"notebook"`, `"talk"`, `"poster"`, or a list.

- font_scale:

  Separate scaling factor applied to the font sizes only.

- rc:

  Optional named list of overrides.

## Value

A named list of context parameters.
