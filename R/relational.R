# Relational plots: scatterplot, lineplot, relplot. Ports of seaborn/relational.py.

#' Draw a scatter plot with semantic mappings
#'
#' Port of `seaborn.scatterplot`. Returns a [reaborn_plot] (a ggplot), so it can
#' be extended with any ggplot2 component.
#'
#' @param data A data frame.
#' @param x,y Column names (strings) or vectors giving the axes.
#' @param hue,size,style Column names/vectors for color, size, and marker-style
#'   semantics.
#' @param palette,hue_order,hue_norm Control the color mapping.
#' @param sizes,size_order,size_norm Control the size mapping.
#' @param markers,style_order Control the style (marker) mapping.
#' @param legend `"auto"`, `"brief"`, `"full"`, or `FALSE`.
#' @param ... Passed to [ggplot2::geom_point].
#' @return A `reaborn_plot`.
#' @examples
#' penguins <- load_dataset("penguins")
#' scatterplot(data = penguins, x = "bill_length_mm", y = "bill_depth_mm", hue = "species")
#'
#' # Add size and style semantics
#' scatterplot(
#'   data = penguins,
#'   x = "bill_length_mm",
#'   y = "bill_depth_mm",
#'   hue = "species",
#'   size = "body_mass_g",
#'   style = "sex"
#' )
#' @export
scatterplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  size = NULL,
  style = NULL,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
  sizes = NULL,
  size_order = NULL,
  size_norm = NULL,
  markers = TRUE,
  style_order = NULL,
  legend = "auto",
  ...
) {
  v <- rb_assign_variables(
    data,
    x = x,
    y = y,
    hue = hue,
    size = size,
    style = style
  )
  mb <- rb_make_base(data, v, c("x", "y", "hue", "size", "style"))
  base <- mb$base
  vd <- mb$vd

  hue_m <- rb_resolve_hue(
    vd[["hue"]],
    v$names$hue %||% "hue",
    v$types$hue %||% "categorical",
    palette,
    hue_order,
    hue_norm,
    aes = "fill"
  )
  size_m <- rb_resolve_size(
    vd[["size"]],
    v$names$size %||% "size",
    v$types$size %||% "categorical",
    sizes,
    size_order,
    size_norm,
    default_range = c(18, 72)
  )
  style_m <- rb_resolve_style(
    vd[["style"]],
    v$names$style %||% "style",
    style_order,
    markers = markers,
    dashes = FALSE
  )

  # Map x/y to their original columns (retaining other columns for faceting).
  rx <- rb_role_col(base, vd, x, "x", "__x")
  base <- rx$base
  ry <- rb_role_col(base, vd, y, "y", "__y")
  base <- ry$base
  mapping <- ggplot2::aes(x = .data[[rx$col]], y = .data[[ry$col]])
  if (isTRUE(hue_m$mapped)) {
    base$`__hue` <- hue_m$column
    mapping$fill <- rlang::sym("__hue")
  }
  if (isTRUE(size_m$mapped)) {
    base$`__size` <- size_m$column
    mapping$size <- rlang::sym("__size")
  }
  if (isTRUE(style_m$mapped)) {
    base$`__style` <- style_m$column
    mapping$shape <- rlang::sym("__style")
  }
  pdf <- base

  # Constant geom defaults (seaborn: filled marker, white edge, auto stroke).
  geom_args <- list(...)
  if (!isTRUE(size_m$mapped) && is.null(geom_args$size)) {
    geom_args$size <- rb_area_to_size(36) # default s = 36 points^2
  }
  if (!isTRUE(style_m$mapped) && is.null(geom_args$shape)) {
    geom_args$shape <- 21
  }
  if (is.null(geom_args$colour)) {
    geom_args$colour <- "white"
  } # marker edge
  if (is.null(geom_args$stroke)) {
    geom_args$stroke <- RB_SCATTER_STROKE
  }
  if (!isTRUE(hue_m$mapped) && is.null(geom_args$fill)) {
    geom_args$fill <- color_palette(.reaborn_get("palette", "deep"), 1)
  }

  p <- ggplot2::ggplot(pdf, mapping) + do.call(ggplot2::geom_point, geom_args)

  # Scales for the active semantics. For fill, use fillable shapes (21-25).
  if (isTRUE(hue_m$mapped)) {
    p <- p + hue_m$scale
  }
  if (isTRUE(size_m$mapped)) {
    p <- p + size_m$scale
  }
  if (isTRUE(style_m$mapped) && !is.null(style_m$shape_scale)) {
    fillable <- c(21, 22, 24, 23, 25)
    p <- p +
      ggplot2::scale_shape_manual(
        values = stats::setNames(
          fillable[seq_along(style_m$levels)],
          style_m$levels
        ),
        name = style_m$name
      )
  }

  p <- rb_finish_plot(
    p,
    xlab = v$names$x,
    ylab = v$names$y,
    legend = legend,
    legend_data = list(x = vd[["x"]], y = vd[["y"]]),
    any_legend = any(hue_m$mapped, size_m$mapped, style_m$mapped)
  )
  reaborn_plot(p, call = match.call())
}

# Default white-edge stroke for scatter markers (seaborn auto-stroke for s=36 is
# 0.08*sqrt(6) ~= 0.48 pt; expressed in ggplot stroke units).
RB_SCATTER_STROKE <- 0.3

#' Draw a line plot with aggregation and error bands
#'
#' Port of `seaborn.lineplot`. When the data has repeated observations per x
#' value, they are aggregated (default: mean) and an error band (default: 95%
#' bootstrap CI) is drawn. Returns a [reaborn_plot].
#'
#' @inheritParams scatterplot
#' @param units,weights Column names/vectors for the unit grouping and weights.
#' @param dashes,markers Style mapping controls.
#' @param estimator Aggregation function name or callable (default `"mean"`;
#'   `NULL` to plot all observations).
#' @param errorbar Error representation: a method name or `list(method, level)`
#'   (default `list("ci", 95)`).
#' @param n_boot,seed Bootstrap settings for `errorbar = "ci"`.
#' @param orient,sort,err_style,err_kws See seaborn.
#' @param ... Passed to [ggplot2::geom_line].
#' @return A `reaborn_plot`.
#' @param style_order Order of style levels.
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @examples
#' fmri <- load_dataset("fmri")
#' # Aggregated mean with a 95% bootstrap CI band across repeated observations
#' lineplot(data = fmri, x = "timepoint", y = "signal", hue = "event")
#' # Add a style semantic to distinguish brain regions
#' lineplot(
#'   data = fmri, x = "timepoint", y = "signal",
#'   hue = "event", style = "region"
#' )
#' @export
lineplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  size = NULL,
  style = NULL,
  units = NULL,
  weights = NULL,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
  sizes = NULL,
  size_order = NULL,
  size_norm = NULL,
  dashes = TRUE,
  markers = NULL,
  style_order = NULL,
  estimator = "mean",
  errorbar = list("ci", 95),
  n_boot = 1000,
  seed = NULL,
  orient = "x",
  sort = TRUE,
  err_style = "band",
  err_kws = NULL,
  legend = "auto",
  .facet_vars = NULL,
  ...
) {
  v <- rb_assign_variables(
    data,
    x = x,
    y = y,
    hue = hue,
    size = size,
    style = style,
    units = units
  )
  mb <- rb_make_base(data, v, c("x", "y", "hue", "size", "style", "units"))
  vd <- mb$vd

  hue_m <- rb_resolve_hue(
    vd[["hue"]],
    v$names$hue %||% "hue",
    v$types$hue %||% "categorical",
    palette,
    hue_order,
    hue_norm,
    aes = "colour"
  )
  size_m <- rb_resolve_size(
    vd[["size"]],
    v$names$size %||% "size",
    v$types$size %||% "categorical",
    sizes,
    size_order,
    size_norm,
    default_range = rb_line_size_range(),
    aes = "linewidth"
  )
  style_m <- rb_resolve_style(
    vd[["style"]],
    v$names$style %||% "style",
    style_order,
    markers = markers %||% FALSE,
    dashes = dashes
  )

  # Assemble an aggregation/plot frame keyed by role.
  adf <- data.frame(.x = vd[["x"]], .y = vd[["y"]])
  grp_cols <- character(0)
  if (isTRUE(hue_m$mapped)) {
    adf$.hue <- hue_m$column
    grp_cols <- c(grp_cols, ".hue")
  }
  if (isTRUE(size_m$mapped)) {
    adf$.size <- size_m$column
    grp_cols <- c(grp_cols, ".size")
  }
  if (isTRUE(style_m$mapped)) {
    adf$.style <- style_m$column
    grp_cols <- c(grp_cols, ".style")
  }
  has_units <- "units" %in% names(vd)
  if (has_units) {
    adf$.units <- factor(as.character(vd[["units"]]))
  }
  # Facet columns (passed by relplot for kind="line"): retained for faceting and
  # used as aggregation grouping so each facet aggregates independently.
  facet_vars <- intersect(.facet_vars %||% character(0), names(mb$base))
  for (fv in facet_vars) {
    adf[[fv]] <- mb$base[[fv]]
    grp_cols <- c(grp_cols, fv)
  }

  aggregate <- !is.null(estimator) && !has_units
  if (aggregate) {
    plotdf <- rb_aggregate(
      adf,
      pos_col = ".x",
      value_col = ".y",
      group_cols = grp_cols,
      estimator = estimator,
      errorbar = errorbar,
      n_boot = n_boot,
      seed = seed
    )
    ycol <- "estimate"
  } else {
    plotdf <- adf
    ycol <- ".y"
  }

  line_grp <- c(grp_cols, if (has_units) ".units")
  plotdf$.grp <- if (length(line_grp)) {
    interaction(plotdf[line_grp], drop = TRUE, lex.order = TRUE)
  } else {
    factor(1)
  }
  if (isTRUE(sort)) {
    plotdf <- plotdf[order(plotdf$.grp, plotdf$.x), , drop = FALSE]
  }

  # Aesthetic mapping.
  mapping <- ggplot2::aes(x = .data$.x, y = .data[[ycol]], group = .data$.grp)
  if (isTRUE(hue_m$mapped)) {
    mapping$colour <- rlang::sym(".hue")
  }
  if (isTRUE(size_m$mapped)) {
    mapping$linewidth <- rlang::sym(".size")
  }
  if (isTRUE(style_m$mapped) && isTRUE(dashes)) {
    mapping$linetype <- rlang::sym(".style")
  }

  default_color <- color_palette(.reaborn_get("palette", "deep"), 1)
  line_args <- list(...)
  if (!isTRUE(size_m$mapped) && is.null(line_args$linewidth)) {
    line_args$linewidth <- rb_line_default_width()
  }
  if (!isTRUE(hue_m$mapped) && is.null(line_args$colour)) {
    line_args$colour <- default_color
  }

  p <- ggplot2::ggplot(plotdf, mapping)

  # Error band / bars first (drawn under the line).
  band_alpha <- (err_kws %||% list())$alpha %||% 0.2
  if (aggregate && !is.null(errorbar) && any(is.finite(plotdf$ymin))) {
    if (identical(err_style, "band")) {
      band_map <- ggplot2::aes(
        x = .data$.x,
        ymin = .data$ymin,
        ymax = .data$ymax,
        group = .data$.grp
      )
      if (isTRUE(hue_m$mapped)) {
        band_map$fill <- rlang::sym(".hue")
      }
      band_args <- list(
        mapping = band_map,
        alpha = band_alpha,
        colour = NA,
        show.legend = FALSE,
        inherit.aes = FALSE
      )
      if (!isTRUE(hue_m$mapped)) {
        band_args$fill <- default_color
      }
      p <- p + do.call(ggplot2::geom_ribbon, band_args)
    } else if (identical(err_style, "bars")) {
      eb_map <- ggplot2::aes(
        x = .data$.x,
        ymin = .data$ymin,
        ymax = .data$ymax,
        group = .data$.grp
      )
      if (isTRUE(hue_m$mapped)) {
        eb_map$colour <- rlang::sym(".hue")
      }
      p <- p +
        ggplot2::geom_errorbar(
          eb_map,
          width = 0,
          show.legend = FALSE,
          inherit.aes = FALSE
        )
    }
  }

  p <- p + do.call(ggplot2::geom_line, line_args)

  # Optional markers.
  if (isTRUE(markers) || is.character(markers)) {
    p <- p + ggplot2::geom_point(size = rb_area_to_size(36))
  }

  # Scales.
  if (isTRUE(hue_m$mapped)) {
    p <- p + hue_m$scale
    if (
      hue_m$type == "categorical" && aggregate && identical(err_style, "band")
    ) {
      p <- p +
        ggplot2::scale_fill_manual(
          values = stats::setNames(
            rb_categorical_colors(length(hue_m$levels), palette),
            hue_m$levels
          ),
          guide = "none"
        )
    }
  }
  if (isTRUE(size_m$mapped)) {
    p <- p + size_m$scale
  }
  if (isTRUE(style_m$mapped) && !is.null(style_m$linetype_scale)) {
    p <- p + style_m$linetype_scale
  }

  p <- rb_finish_plot(
    p,
    xlab = v$names$x,
    ylab = v$names$y,
    legend = legend,
    legend_data = list(x = plotdf$.x, y = plotdf[[ycol]]),
    any_legend = any(hue_m$mapped, size_m$mapped, style_m$mapped)
  )
  reaborn_plot(p, call = match.call())
}

# seaborn line size range = [.5, 2] * lines.linewidth (points). Returned in
# ggplot linewidth (mm) units via the pt->mm conversion.
rb_line_size_range <- function() {
  lw <- SEABORN_DEFAULTS$linewidth
  c(0.5, 2) * lw
}
rb_line_default_width <- function() .rb_lw(SEABORN_DEFAULTS$linewidth)

#' Figure-level interface for relational plots
#'
#' Port of `seaborn.relplot`. Draws [scatterplot] (`kind = "scatter"`) or
#' [lineplot] (`kind = "line"`) onto a grid of facets defined by `row`/`col`.
#' Returns a [reaborn_plot] (a faceted ggplot) with the legend outside, like a
#' seaborn FacetGrid.
#'
#' @inheritParams lineplot
#' @param row,col Column names to facet by.
#' @param col_wrap Wrap the column facets at this width.
#' @param row_order,col_order Facet orderings.
#' @param kind `"scatter"` or `"line"`.
#' @param height,aspect Facet height (inches) and aspect ratio (stored as
#'   attributes used as defaults when saving).
#' @param facet_kws Reserved for compatibility.
#' @return A `reaborn_plot`.
#' @param style_order Order of style levels.
#' @examples
#' fmri <- load_dataset("fmri")
#' relplot(
#'   data = fmri, x = "timepoint", y = "signal",
#'   hue = "event", col = "region", kind = "line"
#' )
#'
#' tips <- load_dataset("tips")
#' relplot(data = tips, x = "total_bill", y = "tip", hue = "day", col = "time")
#' @export
relplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  size = NULL,
  style = NULL,
  units = NULL,
  weights = NULL,
  row = NULL,
  col = NULL,
  col_wrap = NULL,
  row_order = NULL,
  col_order = NULL,
  palette = NULL,
  hue_order = NULL,
  hue_norm = NULL,
  sizes = NULL,
  size_order = NULL,
  size_norm = NULL,
  markers = NULL,
  dashes = NULL,
  style_order = NULL,
  legend = "auto",
  kind = "scatter",
  height = 5,
  aspect = 1,
  facet_kws = NULL,
  ...
) {
  data <- rb_drop_facet_na(data, row, col)
  common <- list(
    data = data,
    x = x,
    y = y,
    hue = hue,
    size = size,
    style = style,
    palette = palette,
    hue_order = hue_order,
    hue_norm = hue_norm,
    sizes = sizes,
    size_order = size_order,
    size_norm = size_norm,
    style_order = style_order,
    legend = legend,
    ...
  )
  if (kind == "line") {
    common$units <- units
    common$markers <- markers %||% FALSE
    common$dashes <- dashes %||% TRUE
    common$.facet_vars <- c(row, col)
    p <- do.call(lineplot, common)
  } else if (kind == "scatter") {
    common$markers <- markers %||% TRUE
    p <- do.call(scatterplot, common)
  } else {
    stop(sprintf("kind must be 'scatter' or 'line', not '%s'", kind))
  }

  # Apply faceting honoring optional level orders.
  p <- rb_facet(p, data, row, col, col_wrap, row_order, col_order)

  # Figure-level functions put the legend OUTSIDE (to the right), like FacetGrid.
  p <- p + rb_legend_right()
  attr(p, "rb_height") <- height
  attr(p, "rb_aspect") <- aspect
  reaborn_plot(p, call = match.call())
}

# Drop rows whose faceting variable is NA. seaborn's FacetGrid builds its row/col
# levels from `categorical_order`, which discards NA, so missing facet values are
# never given a panel. Without this an NA facet level flows downstream as an
# all-NA group selection (e.g. a per-facet KDE over an empty subset), which errors
# in `rb_gaussian_kde`, and otherwise paints a spurious "var = NA" panel.
#' @keywords internal
rb_drop_facet_na <- function(data, row = NULL, col = NULL) {
  if (!is.data.frame(data)) {
    return(data)
  }
  vars <- Filter(
    function(v) is.character(v) && length(v) == 1L && v %in% names(data),
    list(row, col)
  )
  if (!length(vars)) {
    return(data)
  }
  keep <- rep(TRUE, nrow(data))
  for (v in vars) {
    keep <- keep & !is.na(data[[v]])
  }
  data[keep, , drop = FALSE]
}

# Add facet_wrap / facet_grid to a plot from string row/col column names, using
# the "var = value" strip labels seaborn shows, and honoring facet orderings.
rb_facet <- function(
  p,
  data,
  row = NULL,
  col = NULL,
  col_wrap = NULL,
  row_order = NULL,
  col_order = NULL
) {
  if (is.null(row) && is.null(col)) {
    return(p)
  }
  # This is the figure-level facet path (catplot/displot/relplot/lmplot/
  # FacetGrid): facet columns were already forwarded through setup/aggregation,
  # so disable any manual-facet re-aggregation hook to avoid rebuilding twice.
  attr(p, "rb_refacet") <- NULL
  if (is.data.frame(data)) {
    # Re-level facet columns so facets appear in seaborn's categorical order.
    relevel <- function(p, var, order) {
      if (is.null(var)) {
        return(p)
      }
      lv <- rb_categorical_order(data[[var]], order)
      p$data[[var]] <- factor(as.character(p$data[[var]]), levels = lv)
      p
    }
    p <- relevel(p, col, col_order)
    p <- relevel(p, row, row_order)
  }
  labeller <- rb_label_eq
  if (!is.null(col) && is.null(row)) {
    facet <- if (!is.null(col_wrap)) {
      ggplot2::facet_wrap(
        ggplot2::vars(.data[[col]]),
        ncol = col_wrap,
        labeller = labeller
      )
    } else {
      ggplot2::facet_wrap(ggplot2::vars(.data[[col]]), labeller = labeller)
    }
  } else {
    rows <- if (!is.null(row)) ggplot2::vars(.data[[row]]) else NULL
    cols <- if (!is.null(col)) ggplot2::vars(.data[[col]]) else NULL
    facet <- ggplot2::facet_grid(rows = rows, cols = cols, labeller = labeller)
  }
  p + facet
}

# A ggplot2 labeller producing seaborn's "var = value" strip titles.
rb_label_eq <- function(labels) {
  out <- Map(
    function(nm, vals) paste0(nm, " = ", as.character(vals)),
    names(labels),
    labels
  )
  names(out) <- names(labels)
  out
}
