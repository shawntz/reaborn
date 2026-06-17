# Categorical plots: boxplot, countplot, barplot, pointplot, stripplot, catplot.
# Ports of seaborn/categorical.py. Categorical axes use ggplot's native discrete
# positioning (categories at 1..n, hue dodged); fills are desaturated to 0.75 and
# bar edges are white, matching seaborn.

# Resolve the categorical vs value axis, orientation, ordering, and hue. Returns
# a tidy frame plus metadata used by all categorical plotters.
rb_cat_setup <- function(data, x = NULL, y = NULL, hue = NULL, order = NULL,
                         hue_order = NULL, orient = NULL, facet_vars = NULL) {
  v <- rb_assign_variables(data, x = x, y = y, hue = hue)
  vd <- v$data
  has_x <- "x" %in% names(vd); has_y <- "y" %in% names(vd)

  # Determine which axis is categorical.
  if (is.null(orient)) {
    if (has_x && has_y) {
      xnum <- rb_variable_type(vd$x) == "numeric"
      ynum <- rb_variable_type(vd$y) == "numeric"
      orient <- if (xnum && !ynum) "h" else "v"
    } else {
      orient <- "v"
    }
  }

  cat_role <- if (orient == "v") "x" else "y"
  val_role <- if (orient == "v") "y" else "x"
  cat_vals <- vd[[cat_role]]
  val_vals <- if (val_role %in% names(vd)) vd[[val_role]] else NULL

  cat_levels <- if (!is.null(cat_vals)) rb_categorical_order(cat_vals, order) else NULL
  cat_fac <- if (!is.null(cat_vals)) factor(as.character(cat_vals), levels = cat_levels) else NULL

  hue_fac <- NULL; hue_levels <- NULL
  if ("hue" %in% names(vd)) {
    hue_levels <- rb_categorical_order(vd$hue, hue_order)
    hue_fac <- factor(as.character(vd$hue), levels = hue_levels)
  }

  df <- data.frame(.cat = cat_fac %||% factor(rep("", length(val_vals))),
                   .val = val_vals %||% NA_real_, stringsAsFactors = FALSE)
  if (!is.null(hue_fac)) df$.hue <- hue_fac
  # Carry facet columns (for catplot) so faceting works after aggregation.
  fvars <- intersect(facet_vars %||% character(0), names(data))
  for (fv in fvars) df[[fv]] <- data[[fv]]

  list(df = df, orient = orient, cat_levels = cat_levels, hue_levels = hue_levels,
       cat_name = v$names[[cat_role]], val_name = v$names[[val_role]],
       hue_name = v$names$hue, has_hue = !is.null(hue_fac), facet_vars = fvars)
}

# Desaturate a set of colors to `saturation` (seaborn categorical default 0.75).
rb_desat_colors <- function(colors, saturation) {
  if (saturation >= 1) return(colors)
  vapply(colors, desaturate, character(1), prop = saturation)
}

# Resolve fill colors for a categorical plot: one per hue level, or a single
# color when there is no hue.
rb_cat_colors <- function(setup, palette, color, saturation) {
  if (setup$has_hue) {
    cols <- rb_categorical_colors(length(setup$hue_levels), palette)
    stats::setNames(rb_desat_colors(cols, saturation), setup$hue_levels)
  } else {
    base <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)
    rb_desat_colors(base, saturation)
  }
}

# Apply matplotlib-style breaks to the value axis and finish a categorical plot.
rb_cat_finish <- function(p, setup, legend = "auto") {
  val_break <- ggplot2::scale_y_continuous
  if (setup$orient == "h") val_break <- ggplot2::scale_x_continuous
  p <- p + val_break(breaks = rb_mpl_breaks())
  xlab <- if (setup$orient == "v") setup$cat_name else setup$val_name
  ylab <- if (setup$orient == "v") setup$val_name else setup$cat_name
  p <- rb_finish_plot(p, xlab = xlab, ylab = ylab,
                      legend = if (isFALSE(legend)) FALSE else "auto", breaks = FALSE)
  if (setup$has_hue && !isFALSE(legend)) p <- p + ggplot2::theme(legend.position = "right")
  p
}

# Box line color for linecolor="auto" (a mid-dark gray, matching seaborn).
RB_BOX_LINECOLOR <- "#4C4C4C"

#' Draw a box plot
#'
#' Port of `seaborn.boxplot`. Returns a [reaborn_plot].
#'
#' @param data A data frame.
#' @param x,y Variables; the categorical one defines the groups.
#' @param hue Grouping variable for color (dodged).
#' @param order,hue_order Level orderings.
#' @param orient `"v"`, `"h"`, or `NULL` to infer.
#' @param color,palette,saturation,fill Color controls (saturation default 0.75).
#' @param width,gap Box width and gap between dodged boxes.
#' @param whis Whisker length in IQR units (default 1.5).
#' @param linecolor,linewidth,fliersize Line and outlier styling.
#' @param legend Legend control.
#' @param ... Passed to [ggplot2::geom_boxplot].
#' @return A `reaborn_plot`.
#' @export
boxplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, order = NULL,
                    hue_order = NULL, orient = NULL, color = NULL, palette = NULL,
                    saturation = 0.75, fill = TRUE, dodge = "auto", width = 0.8,
                    gap = 0, whis = 1.5, linecolor = "auto", linewidth = NULL,
                    fliersize = NULL, legend = "auto", .facet_vars = NULL, ...) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  colors <- rb_cat_colors(s, palette, color, saturation)
  lc <- if (identical(linecolor, "auto")) RB_BOX_LINECOLOR else linecolor
  lw <- .rb_lw(linewidth %||% 1)
  flier <- (fliersize %||% 5)

  mapping <- if (s$orient == "v") {
    ggplot2::aes(x = .data$.cat, y = .data$.val)
  } else {
    ggplot2::aes(x = .data$.val, y = .data$.cat)
  }
  if (s$has_hue) mapping$fill <- rlang::sym(".hue")

  # seaborn fliers are open circles (shape 1) in the line color; no whisker caps.
  box_args <- list(mapping = mapping, width = width, colour = lc, linewidth = lw,
                   outlier.shape = 1, outlier.size = flier / 2,
                   outlier.colour = lc, outlier.stroke = .rb_lw(1),
                   staplewidth = 0, ...)
  if (!s$has_hue) box_args$fill <- colors

  p <- ggplot2::ggplot(s$df) + do.call(ggplot2::geom_boxplot, box_args)
  if (s$has_hue) {
    p <- p + ggplot2::scale_fill_manual(values = colors, name = s$hue_name)
  }
  p <- rb_cat_finish(p, s, legend)
  reaborn_plot(p, call = match.call())
}

#' Show value counts as bars
#'
#' Port of `seaborn.countplot`. Returns a [reaborn_plot].
#'
#' @inheritParams boxplot
#' @param stat `"count"`, `"percent"`, `"proportion"`, or `"probability"`.
#' @param ... Passed to the bar geom.
#' @return A `reaborn_plot`.
#' @export
countplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, order = NULL,
                      hue_order = NULL, orient = NULL, color = NULL, palette = NULL,
                      saturation = 0.75, fill = TRUE, stat = "count", width = 0.8,
                      dodge = "auto", gap = 0, legend = "auto", .facet_vars = NULL, ...) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  colors <- rb_cat_colors(s, palette, color, saturation)

  # Count per category (x hue x facets).
  grpcols <- c(".cat", if (s$has_hue) ".hue", s$facet_vars)
  counts <- as.data.frame(table(s$df[grpcols]), stringsAsFactors = FALSE)
  names(counts)[seq_along(grpcols)] <- grpcols
  counts$.cat <- factor(counts$.cat, levels = s$cat_levels)
  if (s$has_hue) counts$.hue <- factor(counts$.hue, levels = s$hue_levels)
  total <- sum(counts$Freq)
  counts$value <- switch(stat,
    count = counts$Freq,
    proportion = , probability = counts$Freq / total,
    percent = counts$Freq / total * 100, counts$Freq)

  position <- if (s$has_hue) ggplot2::position_dodge2(preserve = "single") else "stack"
  mapping <- if (s$orient == "v") {
    ggplot2::aes(x = .data$.cat, y = .data$value)
  } else {
    ggplot2::aes(x = .data$value, y = .data$.cat)
  }
  if (s$has_hue) mapping$fill <- rlang::sym(".hue")
  bar_args <- list(mapping = mapping, width = width, colour = "white",
                   linewidth = .rb_lw(1), position = position, stat = "identity", ...)
  if (!s$has_hue) bar_args$fill <- colors
  p <- ggplot2::ggplot(counts) + do.call(ggplot2::geom_bar, bar_args)
  if (s$has_hue) p <- p + ggplot2::scale_fill_manual(values = colors, name = s$hue_name)

  s$val_name <- switch(stat, count = "Count", percent = "Percent",
                       proportion = , probability = "Proportion", "Count")
  # countplot value axis starts at 0.
  if (s$orient == "v") {
    p <- p + ggplot2::scale_y_continuous(breaks = rb_mpl_breaks(),
                                         expand = ggplot2::expansion(mult = c(0, 0.05)))
  } else {
    p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks(),
                                         expand = ggplot2::expansion(mult = c(0, 0.05)))
  }
  xlab <- if (s$orient == "v") s$cat_name else s$val_name
  ylab <- if (s$orient == "v") s$val_name else s$cat_name
  p <- rb_finish_plot(p, xlab = xlab, ylab = ylab,
                      legend = if (isFALSE(legend)) FALSE else "auto", breaks = FALSE)
  if (s$has_hue && !isFALSE(legend)) p <- p + ggplot2::theme(legend.position = "right")
  reaborn_plot(p, call = match.call())
}

# Aggregate a categorical setup's value by (cat, hue, facets) into est/ymin/ymax.
rb_cat_aggregate <- function(s, estimator, errorbar, n_boot, seed) {
  grp <- c(if (s$has_hue) ".hue", s$facet_vars)
  agg <- rb_aggregate(s$df, pos_col = ".cat", value_col = ".val", group_cols = grp,
                      estimator = estimator, errorbar = errorbar, n_boot = n_boot,
                      seed = seed)
  agg$.cat <- factor(as.character(agg$.cat), levels = s$cat_levels)
  if (s$has_hue) agg$.hue <- factor(as.character(agg$.hue), levels = s$hue_levels)
  agg
}

#' Show point estimates and errors as bars
#'
#' Port of `seaborn.barplot`. Bar heights are an aggregate (default mean) with a
#' bootstrap CI error bar. Returns a [reaborn_plot].
#'
#' @inheritParams boxplot
#' @param estimator,errorbar,n_boot,seed Aggregation + error settings.
#' @param units,weights Bootstrap structure / weights (units reserved).
#' @param capsize Width of the error bar caps.
#' @param err_kws Passed to the error bar geom.
#' @param ... Passed to the bar geom.
#' @return A `reaborn_plot`.
#' @export
barplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, order = NULL,
                    hue_order = NULL, estimator = "mean", errorbar = list("ci", 95),
                    n_boot = 1000, seed = NULL, units = NULL, weights = NULL,
                    orient = NULL, color = NULL, palette = NULL, saturation = 0.75,
                    fill = TRUE, width = 0.8, dodge = "auto", gap = 0,
                    capsize = 0, err_kws = NULL, legend = "auto", .facet_vars = NULL, ...) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  colors <- rb_cat_colors(s, palette, color, saturation)
  agg <- rb_cat_aggregate(s, estimator, errorbar, n_boot, seed)

  vert <- s$orient == "v"
  dodge_w <- if (s$has_hue) ggplot2::position_dodge(width = width) else "identity"
  bar_aes <- if (vert) ggplot2::aes(x = .data$.cat, y = .data$estimate)
             else ggplot2::aes(x = .data$estimate, y = .data$.cat)
  if (s$has_hue) bar_aes$fill <- rlang::sym(".hue")
  bar_args <- list(mapping = bar_aes, width = width, colour = "white",
                   linewidth = .rb_lw(1), stat = "identity", position = dodge_w, ...)
  if (!s$has_hue) bar_args$fill <- colors
  p <- ggplot2::ggplot(agg) + do.call(ggplot2::geom_col, bar_args)

  # Error bars (bootstrap CI).
  ek <- err_kws %||% list()
  err_aes <- if (vert) ggplot2::aes(x = .data$.cat, ymin = .data$ymin, ymax = .data$ymax,
                                    group = if (s$has_hue) .data$.hue else NULL)
             else ggplot2::aes(y = .data$.cat, xmin = .data$ymin, xmax = .data$ymax,
                               group = if (s$has_hue) .data$.hue else NULL)
  err_fun <- if (vert) ggplot2::geom_errorbar else ggplot2::geom_errorbarh
  p <- p + err_fun(err_aes, position = dodge_w, width = capsize,
                   colour = ek$color %||% RB_BOX_LINECOLOR,
                   linewidth = .rb_lw(ek$linewidth %||% 1.5))

  if (s$has_hue) p <- p + ggplot2::scale_fill_manual(values = colors, name = s$hue_name)
  # Bars start at 0.
  exp0 <- ggplot2::expansion(mult = c(0, 0.05))
  if (vert) p <- p + ggplot2::scale_y_continuous(breaks = rb_mpl_breaks(), expand = exp0)
  else p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks(), expand = exp0)
  xlab <- if (vert) s$cat_name else s$val_name
  ylab <- if (vert) s$val_name else s$cat_name
  p <- rb_finish_plot(p, xlab = xlab, ylab = ylab,
                      legend = if (isFALSE(legend)) FALSE else "auto", breaks = FALSE)
  if (s$has_hue && !isFALSE(legend)) p <- p + ggplot2::theme(legend.position = "right")
  reaborn_plot(p, call = match.call())
}

#' Draw a categorical scatter with jitter
#'
#' Port of `seaborn.stripplot`. Returns a [reaborn_plot].
#'
#' @inheritParams boxplot
#' @param jitter `TRUE`, `FALSE`, or a numeric jitter amount.
#' @param dodge Separate hue levels along the categorical axis.
#' @param size Marker size (seaborn default 5).
#' @param edgecolor,linewidth Marker edge styling.
#' @param ... Passed to the point geom.
#' @return A `reaborn_plot`.
#' @export
stripplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, order = NULL,
                      hue_order = NULL, jitter = TRUE, dodge = FALSE, orient = NULL,
                      color = NULL, palette = NULL, size = 5, edgecolor = "gray",
                      linewidth = 0, legend = "auto", .facet_vars = NULL, ...) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  vert <- s$orient == "v"
  if (s$has_hue) {
    colors <- stats::setNames(rb_categorical_colors(length(s$hue_levels), palette), s$hue_levels)
  } else {
    colors <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)
  }
  jit <- if (isTRUE(jitter)) 0.1 else if (is.numeric(jitter)) jitter else 0
  position <- if (isTRUE(dodge) && s$has_hue) {
    ggplot2::position_jitterdodge(jitter.width = jit, dodge.width = 0.8)
  } else {
    ggplot2::position_jitter(width = if (vert) jit else 0, height = if (vert) 0 else jit)
  }
  pt_aes <- if (vert) ggplot2::aes(x = .data$.cat, y = .data$.val)
            else ggplot2::aes(x = .data$.val, y = .data$.cat)
  if (s$has_hue) pt_aes$colour <- rlang::sym(".hue")
  pt_args <- list(pt_aes, position = position, size = rb_area_to_size(size^2),
                  stroke = linewidth, ...)
  if (!s$has_hue) pt_args$colour <- colors
  p <- ggplot2::ggplot(s$df) + do.call(ggplot2::geom_point, pt_args)
  if (s$has_hue) p <- p + ggplot2::scale_colour_manual(values = colors, name = s$hue_name)
  p <- rb_cat_finish(p, s, legend)
  reaborn_plot(p, call = match.call())
}

#' Show point estimates and errors with markers
#'
#' Port of `seaborn.pointplot`. Returns a [reaborn_plot].
#'
#' @inheritParams barplot
#' @param markers,linestyles Marker and line styling.
#' @param dodge Dodge points by hue.
#' @return A `reaborn_plot`.
#' @export
pointplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, order = NULL,
                      hue_order = NULL, estimator = "mean", errorbar = list("ci", 95),
                      n_boot = 1000, seed = NULL, units = NULL, weights = NULL,
                      color = NULL, palette = NULL, markers = "o", linestyles = "-",
                      dodge = FALSE, orient = NULL, capsize = 0, legend = "auto",
                      err_kws = NULL, .facet_vars = NULL, ...) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  agg <- rb_cat_aggregate(s, estimator, errorbar, n_boot, seed)
  vert <- s$orient == "v"
  if (s$has_hue) {
    colors <- stats::setNames(rb_categorical_colors(length(s$hue_levels), palette), s$hue_levels)
  } else {
    colors <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)
  }
  dw <- if (isTRUE(dodge)) 0.4 else if (is.numeric(dodge)) dodge else 0
  pos <- if (dw > 0) ggplot2::position_dodge(width = dw) else "identity"

  pt_aes <- if (vert) ggplot2::aes(x = .data$.cat, y = .data$estimate)
            else ggplot2::aes(x = .data$estimate, y = .data$.cat)
  err_aes <- if (vert) ggplot2::aes(x = .data$.cat, ymin = .data$ymin, ymax = .data$ymax)
             else ggplot2::aes(y = .data$.cat, xmin = .data$ymin, xmax = .data$ymax)
  if (s$has_hue) {
    pt_aes$colour <- rlang::sym(".hue"); pt_aes$group <- rlang::sym(".hue")
    err_aes$colour <- rlang::sym(".hue"); err_aes$group <- rlang::sym(".hue")
  }
  err_fun <- if (vert) ggplot2::geom_errorbar else ggplot2::geom_errorbarh
  line_args <- list(pt_aes, position = pos, linewidth = rb_line_default_width())
  pt_args <- list(pt_aes, position = pos, size = rb_area_to_size(36))
  if (!s$has_hue) { line_args$colour <- colors; pt_args$colour <- colors }

  err_args <- list(err_aes, position = pos, width = capsize,
                   linewidth = .rb_lw(1.5), show.legend = FALSE)
  if (!s$has_hue) err_args$colour <- colors
  p <- ggplot2::ggplot(agg) +
    do.call(err_fun, err_args) +
    do.call(ggplot2::geom_line, line_args) +
    do.call(ggplot2::geom_point, pt_args)
  if (s$has_hue) {
    p <- p + ggplot2::scale_colour_manual(values = colors, name = s$hue_name)
  }
  p <- rb_cat_finish(p, s, legend)
  reaborn_plot(p, call = match.call())
}

#' Figure-level interface for categorical plots
#'
#' Port of `seaborn.catplot`. Dispatches to [stripplot] (`kind = "strip"`),
#' [boxplot], [barplot], [pointplot], or [countplot] and adds row/col faceting.
#' Returns a faceted [reaborn_plot].
#'
#' @inheritParams boxplot
#' @param row,col,col_wrap,row_order,col_order Faceting controls.
#' @param kind One of `"strip"`, `"box"`, `"bar"`, `"point"`, `"count"`.
#' @param estimator,errorbar,n_boot,seed Aggregation settings (bar/point).
#' @param height,aspect Facet sizing (stored as attributes).
#' @param facet_kws Reserved for compatibility.
#' @param ... Passed to the underlying plotter.
#' @return A `reaborn_plot`.
#' @export
catplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, row = NULL,
                    col = NULL, kind = "strip", estimator = "mean",
                    errorbar = list("ci", 95), n_boot = 1000, seed = NULL,
                    units = NULL, weights = NULL, order = NULL, hue_order = NULL,
                    row_order = NULL, col_order = NULL, col_wrap = NULL,
                    height = 5, aspect = 1, orient = NULL, color = NULL,
                    palette = NULL, legend = "auto", facet_kws = NULL, ...) {
  fun <- switch(kind, strip = stripplot, box = boxplot, bar = barplot,
                point = pointplot, count = countplot,
                stop(sprintf("kind must be strip/box/bar/point/count, not '%s'", kind)))
  args <- list(data = data, x = x, y = y, hue = hue, order = order,
               hue_order = hue_order, orient = orient, color = color,
               palette = palette, legend = legend, .facet_vars = c(row, col), ...)
  if (kind %in% c("bar", "point")) {
    args$estimator <- estimator; args$errorbar <- errorbar
    args$n_boot <- n_boot; args$seed <- seed
  }
  p <- do.call(fun, args)
  p <- rb_facet(p, data, row, col, col_wrap, row_order, col_order)
  if (!is.null(row) || !is.null(col)) p <- p + ggplot2::theme(legend.position = "right")
  attr(p, "rb_height") <- height
  attr(p, "rb_aspect") <- aspect
  reaborn_plot(p, call = match.call())
}
