# Multi-plot grids: jointplot, pairplot (and lightweight FacetGrid). These
# compose several reaborn plots with patchwork, mirroring seaborn's JointGrid /
# PairGrid figure-level layouts.

# Strip a marginal plot down to a clean density/histogram strip (no axis titles,
# ticks, or background) aligned to the joint axes.
.rb_marginal_theme <- function(axis = "x") {
  base <- ggplot2::theme(
    axis.title = ggplot2::element_blank(),
    legend.position = "none",
    plot.background = ggplot2::element_blank(),
    panel.background = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank()
  )
  if (axis == "x") {
    base +
      ggplot2::theme(
        axis.title.x = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.ticks.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      )
  } else {
    base +
      ggplot2::theme(
        axis.text = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank()
      )
  }
}

#' Draw a bivariate plot with marginal distributions
#'
#' Port of `seaborn.jointplot`. Returns a patchwork composition (printable and
#' saveable like any reaborn plot).
#'
#' @param data A data frame.
#' @param x,y Variables.
#' @param hue Grouping variable for color.
#' @param kind `"scatter"`, `"kde"`, `"reg"`, `"hist"`, or `"hex"`.
#' @param height Figure size in inches (stored as an attribute).
#' @param ratio Joint-axes-to-marginal size ratio.
#' @param space Spacing between joint and marginal axes.
#' @param color,palette Color controls.
#' @param ... Passed to the joint plotting function.
#' @return A `reaborn_plot` (patchwork).
#' @export
jointplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  kind = "scatter",
  height = 6,
  ratio = 5,
  space = 0.2,
  color = NULL,
  palette = NULL,
  ...
) {
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("jointplot() requires the 'patchwork' package.")
  }
  main <- switch(
    kind,
    scatter = scatterplot(
      data = data,
      x = x,
      y = y,
      hue = hue,
      palette = palette,
      legend = FALSE,
      ...
    ),
    kde = kdeplot(data = data, x = x, y = y, hue = hue, palette = palette, ...),
    reg = regplot(data = data, x = x, y = y, color = color, ...),
    hist = histplot(data = data, x = x, y = y, ...),
    hex = scatterplot(data = data, x = x, y = y, legend = FALSE),
    scatterplot(data = data, x = x, y = y, hue = hue, legend = FALSE)
  )
  main <- main + ggplot2::theme(legend.position = "none")

  marg_kind <- if (kind %in% c("kde")) "kde" else "hist"
  mfun <- if (marg_kind == "kde") kdeplot else histplot
  top <- mfun(
    data = data,
    x = x,
    hue = hue,
    palette = palette,
    legend = FALSE
  ) +
    .rb_marginal_theme("x")
  right <- mfun(
    data = data,
    y = y,
    hue = hue,
    palette = palette,
    legend = FALSE
  ) +
    .rb_marginal_theme("y")

  layout <- top +
    patchwork::plot_spacer() +
    main +
    right +
    patchwork::plot_layout(
      ncol = 2,
      nrow = 2,
      widths = c(ratio, 1),
      heights = c(1, ratio)
    )
  attr(layout, "rb_height") <- height
  reaborn_plot(layout, call = match.call())
}

#' Plot pairwise relationships in a dataset
#'
#' Port of `seaborn.pairplot`. Returns a patchwork matrix of scatter plots with
#' univariate distributions on the diagonal.
#'
#' @param data A data frame.
#' @param vars Columns to include (default all numeric).
#' @param hue Grouping variable for color.
#' @param kind Off-diagonal kind: `"scatter"` or `"reg"`.
#' @param diag_kind Diagonal kind: `"auto"`, `"hist"`, or `"kde"`.
#' @param palette,height,aspect,corner Layout controls.
#' @param ... Reserved.
#' @return A `reaborn_plot` (patchwork).
#' @export
pairplot <- function(
  data,
  vars = NULL,
  hue = NULL,
  kind = "scatter",
  diag_kind = "auto",
  palette = NULL,
  height = 2.5,
  aspect = 1,
  corner = FALSE,
  ...
) {
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("pairplot() requires the 'patchwork' package.")
  }
  if (is.null(vars)) {
    vars <- names(data)[vapply(data, is.numeric, logical(1))]
  }
  if (identical(diag_kind, "auto")) {
    diag_kind <- if (is.null(hue)) "hist" else "kde"
  }
  n <- length(vars)
  plots <- vector("list", n * n)
  idx <- 1
  for (i in seq_len(n)) {
    for (j in seq_len(n)) {
      yi <- vars[i]
      xj <- vars[j]
      if (i == j) {
        pl <- if (diag_kind == "kde") {
          kdeplot(
            data = data,
            x = xj,
            hue = hue,
            palette = palette,
            legend = FALSE
          )
        } else {
          histplot(
            data = data,
            x = xj,
            hue = hue,
            palette = palette,
            legend = FALSE
          )
        }
      } else if (kind == "reg") {
        pl <- regplot(data = data, x = xj, y = yi)
      } else {
        pl <- scatterplot(
          data = data,
          x = xj,
          y = yi,
          hue = hue,
          palette = palette,
          legend = FALSE
        )
      }
      # Only show axis titles on the outer edges.
      pl <- pl + ggplot2::theme(legend.position = "none")
      if (i != n) {
        pl <- pl + ggplot2::theme(axis.title.x = ggplot2::element_blank())
      }
      if (j != 1) {
        pl <- pl + ggplot2::theme(axis.title.y = ggplot2::element_blank())
      }
      plots[[idx]] <- pl
      idx <- idx + 1
    }
  }
  grid <- patchwork::wrap_plots(plots, ncol = n, nrow = n)
  attr(grid, "rb_height") <- height
  reaborn_plot(grid, call = match.call())
}

#' A faceted grid of plots
#'
#' Lightweight port of `seaborn.FacetGrid`. In reaborn, faceting is usually done
#' by adding `+ ggplot2::facet_wrap()`/`facet_grid()` to a plot, or via the
#' figure-level functions ([relplot], [displot], [catplot], [lmplot]). This
#' constructor returns a base plot you can map geoms onto.
#'
#' @param data A data frame.
#' @param row,col,hue Faceting / hue variables.
#' @param col_wrap Wrap columns at this width.
#' @param height,aspect Facet sizing.
#' @param palette Hue palette.
#' @return A `reaborn_plot`.
#' @export
FacetGrid <- function(
  data,
  row = NULL,
  col = NULL,
  hue = NULL,
  col_wrap = NULL,
  height = 3,
  aspect = 1,
  palette = NULL
) {
  p <- ggplot2::ggplot(data)
  if (!is.null(hue)) {
    colors <- rb_categorical_colors(
      length(rb_categorical_order(data[[hue]])),
      palette
    )
    p <- p +
      ggplot2::aes(colour = .data[[hue]]) +
      ggplot2::scale_colour_manual(values = colors)
  }
  p <- rb_facet(p, data, row, col, col_wrap)
  attr(p, "rb_height") <- height
  attr(p, "rb_aspect") <- aspect
  reaborn_plot(p, call = match.call())
}
