# Distribution plots: histplot, kdeplot, ecdfplot, rugplot, displot. Ports of
# seaborn/distributions.py. The statistics (bin counts, KDE density, ECDF) are
# computed in R via the exact scipy/numpy ports in core-density.R, then drawn
# with geoms, so reaborn does not inherit ggplot2's different binning/bandwidth.

# Weighted bin counts for one group on fixed edges.
.rb_bin_counts <- function(x, edges, weights = NULL) {
  w <- weights %||% rep(1, length(x))
  idx <- findInterval(x, edges, rightmost.closed = TRUE, all.inside = TRUE)
  counts <- numeric(length(edges) - 1)
  tab <- tapply(w, factor(idx, levels = seq_along(counts)), sum)
  counts[!is.na(tab)] <- tab[!is.na(tab)]
  counts
}

# Normalize a count vector to a statistic, optionally using a shared total
# (common_norm) across groups.
.rb_hist_stat <- function(counts, widths, stat, total = NULL) {
  tot <- total %||% sum(counts)
  switch(stat,
    count = counts,
    frequency = counts / widths,
    density = counts / (tot * widths),
    probability = ,
    proportion = counts / tot,
    percent = counts / tot * 100,
    stop(sprintf("Unknown stat '%s'", stat))
  )
}

#' Plot a univariate or bivariate histogram
#'
#' Port of `seaborn.histplot`. Returns a [reaborn_plot].
#'
#' @param data A data frame.
#' @param x,y Column name/vector for the histogram variable (use `y` for a
#'   horizontal histogram).
#' @param hue Grouping variable for color.
#' @param weights Optional observation weights.
#' @param stat One of `"count"`, `"frequency"`, `"density"`, `"probability"`,
#'   `"proportion"`, `"percent"`.
#' @param bins,binwidth,binrange,discrete Binning controls (see [rb_hist_bins]).
#' @param cumulative Accumulate counts.
#' @param common_bins,common_norm Share bins/normalization across hue groups.
#' @param multiple `"layer"`, `"stack"`, `"fill"`, or `"dodge"`.
#' @param element `"bars"` or `"step"`.
#' @param fill Whether to fill the bars.
#' @param shrink Shrink bar widths by this factor.
#' @param kde Overlay a KDE curve.
#' @param kde_kws Arguments for the KDE (e.g. `bw_adjust`).
#' @param palette,hue_order,hue_norm,color Color controls.
#' @param legend Show the legend.
#' @param ... Passed to the bar geom.
#' @return A `reaborn_plot`.
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @export
histplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, weights = NULL,
                     stat = "count", bins = "auto", binwidth = NULL, binrange = NULL,
                     discrete = NULL, cumulative = FALSE, common_bins = TRUE,
                     common_norm = TRUE, multiple = "layer", element = "bars",
                     fill = TRUE, shrink = 1, kde = FALSE, kde_kws = NULL,
                     palette = NULL, hue_order = NULL, hue_norm = NULL, color = NULL,
                     legend = TRUE, .facet_vars = NULL, ...) {
  horizontal <- is.null(x) && !is.null(y)
  vvar <- if (horizontal) y else x
  v <- rb_assign_variables(data, val = vvar, hue = hue, weights = weights)
  mb <- rb_make_base(data, v, c("val", "hue", "weights"))
  vd <- mb$vd
  vals <- vd[["val"]]
  facet_vars <- intersect(.facet_vars %||% character(0), names(mb$base))
  wts <- vd[["weights"]]

  hue_present <- "hue" %in% names(vd)
  if (hue_present) {
    levels <- rb_categorical_order(vd[["hue"]], hue_order)
    groups <- factor(as.character(vd[["hue"]]), levels = levels)
    colors <- rb_categorical_colors(length(levels), palette)
  } else {
    levels <- "_all"; groups <- factor(rep("_all", length(vals)))
    colors <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)
  }
  names(colors) <- levels

  # Bin edges: shared across groups when common_bins (the default).
  if (isTRUE(discrete)) discrete <- TRUE else discrete <- isTRUE(discrete)
  edges <- rb_hist_bins(vals, bins, binrange, binwidth, discrete)
  widths <- diff(edges) * shrink
  mids <- edges[-length(edges)] + diff(edges) / 2
  grand_total <- sum(!is.na(vals))

  # Per-group statistic, split by hue level and (for displot) facet combination.
  work <- data.frame(.val = vals, .group = groups, stringsAsFactors = FALSE)
  for (fv in facet_vars) work[[fv]] <- mb$base[[fv]]
  if (!is.null(wts)) work$.w <- wts
  combos <- unique(work[c(".group", facet_vars)])
  bars <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
    sel <- work$.group == combos$.group[i]
    for (fv in facet_vars) sel <- sel & as.character(work[[fv]]) == as.character(combos[i, fv])
    gx <- work$.val[sel]
    gw <- if (!is.null(wts)) work$.w[sel] else NULL
    cnt <- .rb_bin_counts(gx, edges, gw)
    if (cumulative) cnt <- cumsum(cnt)
    total <- if (common_norm) grand_total else sum(cnt)
    yval <- .rb_hist_stat(cnt, diff(edges), stat, total = total)
    row <- data.frame(group = combos$.group[i], xmid = mids, xmin = mids - widths / 2,
                      xmax = mids + widths / 2, y = yval, stringsAsFactors = FALSE)
    for (fv in facet_vars) row[[fv]] <- combos[i, fv]
    row
  }))
  bars$group <- factor(bars$group, levels = levels)

  # Positioning for `multiple`.
  bars <- rb_hist_position(bars, multiple)

  # Build the plot. For horizontal, swap x/y roles.
  alpha <- rb_hist_alpha(fill, hue_present, multiple, element, kde)
  edge_col <- "white"
  p <- ggplot2::ggplot(bars)
  rect_aes <- if (horizontal) {
    ggplot2::aes(ymin = .data$xmin, ymax = .data$xmax,
                 xmin = .data$ymin, xmax = .data$ymax, fill = .data$group)
  } else {
    ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax,
                 ymin = .data$ymin, ymax = .data$ymax, fill = .data$group)
  }
  if (element == "bars") {
    p <- p + ggplot2::geom_rect(rect_aes, colour = edge_col,
                                linewidth = .rb_lw(0.5), alpha = alpha,
                                show.legend = hue_present, ...)
  } else {
    # step: outline only
    step_aes <- if (horizontal) {
      ggplot2::aes(x = .data$y, y = .data$xmid, colour = .data$group)
    } else {
      ggplot2::aes(x = .data$xmid, y = .data$y, colour = .data$group)
    }
    p <- p + ggplot2::geom_step(step_aes, direction = "mid",
                                show.legend = hue_present, ...)
  }

  p <- p + ggplot2::scale_fill_manual(values = colors, name = v$names$hue)
  # The colour scale is only needed when something is stroked by group (step
  # element or KDE overlay); adding it otherwise warns about unused levels.
  if (element == "step" || isTRUE(kde)) {
    p <- p + ggplot2::scale_colour_manual(values = colors, name = v$names$hue)
  }
  if (!hue_present) p <- p + ggplot2::guides(fill = "none", colour = "none")

  # KDE overlay (scaled to the histogram when stat allows).
  if (isTRUE(kde)) {
    p <- rb_add_kde_overlay(p, vals, groups, levels, colors, stat, horizontal,
                            kde_kws, edges, grand_total, common_norm)
  }

  # matplotlib-style breaks; the count axis starts exactly at 0 (bars on axis).
  count_expand <- ggplot2::expansion(mult = c(0, 0.05))
  if (horizontal) {
    p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks(), expand = count_expand) +
      ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
  } else {
    p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
      ggplot2::scale_y_continuous(breaks = rb_mpl_breaks(), expand = count_expand)
  }

  ylab <- rb_stat_label(stat)
  # seaborn places the hue legend inside the axes (best corner).
  ld <- if (horizontal) list(x = bars$y, y = bars$xmid) else list(x = bars$xmid, y = bars$ymax)
  p <- rb_finish_plot(
    p,
    xlab = if (horizontal) ylab else v$names$val,
    ylab = if (horizontal) v$names$val else ylab,
    legend = if (isFALSE(legend)) FALSE else "auto",
    legend_data = ld, any_legend = hue_present, breaks = FALSE
  )
  reaborn_plot(p, call = match.call())
}

# Apply stacking / filling / dodging to the per-group bar frame.
rb_hist_position <- function(bars, multiple) {
  bars$ymin <- 0; bars$ymax <- bars$y
  if (multiple %in% c("stack", "fill")) {
    split_by <- split(seq_len(nrow(bars)), bars$xmid)
    for (idx in split_by) {
      sub <- bars[idx, , drop = FALSE]
      sub <- sub[order(sub$group), ]
      cum <- cumsum(sub$y)
      ymin <- c(0, cum[-length(cum)])
      ymax <- cum
      if (multiple == "fill") {
        tot <- max(cum, 1e-9)
        ymin <- ymin / tot; ymax <- ymax / tot
      }
      bars$ymin[idx[order(bars$group[idx])]] <- ymin
      bars$ymax[idx[order(bars$group[idx])]] <- ymax
    }
  } else if (multiple == "dodge") {
    split_by <- split(seq_len(nrow(bars)), bars$xmid)
    for (idx in split_by) {
      g <- bars$group[idx]
      n <- length(levels(g))
      pos <- as.integer(g)
      w <- (bars$xmax[idx] - bars$xmin[idx])
      x0 <- bars$xmin[idx]
      bars$xmin[idx] <- x0 + (pos - 1) * w / n
      bars$xmax[idx] <- x0 + pos * w / n
    }
  }
  bars
}

# seaborn's default histogram alpha (distributions.py).
rb_hist_alpha <- function(fill, hue, multiple, element, kde) {
  if (!fill) return(1)
  if (hue && multiple == "layer") return(if (element == "bars") 0.5 else 0.25)
  if (kde) return(0.5)
  0.75
}

# Axis label for a histogram statistic.
rb_stat_label <- function(stat) {
  switch(stat, count = "Count", frequency = "Frequency", density = "Density",
         probability = "Probability", proportion = "Proportion",
         percent = "Percent", stat)
}

# Overlay KDE curves on a histogram, rescaled to match the histogram's stat.
rb_add_kde_overlay <- function(p, vals, groups, levels, colors, stat, horizontal,
                               kde_kws, edges, grand_total, common_norm) {
  kk <- kde_kws %||% list()
  curves <- do.call(rbind, lapply(levels, function(lv) {
    gx <- vals[groups == lv]
    if (length(gx) < 2) return(NULL)
    est <- rb_gaussian_kde(gx, bw_adjust = kk$bw_adjust %||% 1)
    n <- if (common_norm) grand_total else length(gx)
    binw <- mean(diff(edges))
    scale <- switch(stat,
      count = length(gx) * binw,
      frequency = length(gx),
      probability = , proportion = length(gx) / n,
      percent = length(gx) / n * 100,
      density = 1)
    data.frame(group = lv, x = est$x, y = est$y * scale, stringsAsFactors = FALSE)
  }))
  if (is.null(curves)) return(p)
  curves$group <- factor(curves$group, levels = levels)
  line_aes <- if (horizontal) {
    ggplot2::aes(x = .data$y, y = .data$x, colour = .data$group)
  } else {
    ggplot2::aes(x = .data$x, y = .data$y, colour = .data$group)
  }
  p + ggplot2::geom_line(data = curves, mapping = line_aes,
                         linewidth = rb_line_default_width(), show.legend = FALSE)
}

#' Plot a univariate or bivariate kernel density estimate
#'
#' Port of `seaborn.kdeplot`. The KDE matches `scipy.stats.gaussian_kde` exactly.
#' Returns a [reaborn_plot].
#'
#' @inheritParams histplot
#' @param fill Fill under the density curve (default `FALSE`).
#' @param multiple `"layer"`, `"stack"`, or `"fill"`.
#' @param common_norm,common_grid Share normalization / evaluation grid across
#'   hue groups.
#' @param cumulative Plot the cumulative distribution.
#' @param bw_method,bw_adjust Bandwidth controls (scipy-compatible).
#' @param gridsize,cut,clip KDE grid controls.
#' @param levels,thresh Bivariate contour levels and density threshold.
#' @return A `reaborn_plot`.
#' @param log_scale Reserved for compatibility.
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @export
kdeplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, weights = NULL,
                    palette = NULL, hue_order = NULL, hue_norm = NULL, color = NULL,
                    fill = NULL, multiple = "layer", common_norm = TRUE,
                    common_grid = FALSE, cumulative = FALSE, bw_method = "scott",
                    bw_adjust = 1, log_scale = NULL, levels = 10, thresh = 0.05,
                    gridsize = 200, cut = 3, clip = NULL, legend = TRUE,
                    .facet_vars = NULL, ...) {
  bivariate <- !is.null(x) && !is.null(y)
  if (bivariate) {
    return(rb_kdeplot_bivariate(data, x, y, hue, palette, hue_order, color,
                                fill, levels, thresh, bw_adjust, gridsize, cut,
                                legend, ...))
  }

  horizontal <- is.null(x) && !is.null(y)
  vvar <- if (horizontal) y else x
  v <- rb_assign_variables(data, val = vvar, hue = hue, weights = weights)
  mb <- rb_make_base(data, v, c("val", "hue", "weights"))
  vd <- mb$vd
  vals <- vd[["val"]]

  hue_present <- "hue" %in% names(vd)
  if (hue_present) {
    lv <- rb_categorical_order(vd[["hue"]], hue_order)
    groups <- factor(as.character(vd[["hue"]]), levels = lv)
    colors <- stats::setNames(rb_categorical_colors(length(lv), palette), lv)
  } else {
    lv <- "_all"; groups <- factor(rep("_all", length(vals)))
    colors <- stats::setNames(color %||% color_palette(.reaborn_get("palette", "deep"), 1), lv)
  }

  total <- length(vals)
  shared_clip <- clip
  facet_vars <- intersect(.facet_vars %||% character(0), names(mb$base))
  work <- data.frame(.val = vals, .group = groups, stringsAsFactors = FALSE)
  for (fv in facet_vars) work[[fv]] <- mb$base[[fv]]
  combos <- unique(work[c(".group", facet_vars)])

  curves <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
    sel <- work$.group == combos$.group[i]
    for (fv in facet_vars) sel <- sel & as.character(work[[fv]]) == as.character(combos[i, fv])
    gx <- work$.val[sel]
    if (length(gx) < 2) return(NULL)
    est <- rb_gaussian_kde(gx, bw_method, bw_adjust, gridsize, cut, shared_clip,
                           cumulative = cumulative)
    if (common_norm && !cumulative) est$y <- est$y * length(gx) / total
    row <- data.frame(group = combos$.group[i], x = est$x, y = est$y, stringsAsFactors = FALSE)
    for (fv in facet_vars) row[[fv]] <- combos[i, fv]
    row
  }))
  curves$group <- factor(curves$group, levels = lv)

  # multiple = stack / fill positioning (on a shared grid).
  if (multiple %in% c("stack", "fill") && hue_present && common_grid) {
    curves <- rb_kde_stack(curves, multiple, lv)
  }

  do_fill <- isTRUE(fill)
  aes_line <- if (horizontal) {
    ggplot2::aes(x = .data$y, y = .data$x, colour = .data$group, group = .data$group)
  } else {
    ggplot2::aes(x = .data$x, y = .data$y, colour = .data$group, group = .data$group)
  }
  p <- ggplot2::ggplot(curves)
  if (do_fill) {
    fill_aes <- if (horizontal) {
      ggplot2::aes(y = .data$x, xmin = 0, xmax = .data$y, fill = .data$group, group = .data$group)
    } else {
      ggplot2::aes(x = .data$x, ymin = 0, ymax = .data$y, fill = .data$group, group = .data$group)
    }
    p <- p + ggplot2::geom_ribbon(fill_aes, alpha = 0.25, colour = NA,
                                  show.legend = hue_present) +
      ggplot2::scale_fill_manual(values = colors, name = v$names$hue)
  }
  p <- p + ggplot2::geom_line(aes_line, linewidth = rb_line_default_width(),
                              show.legend = hue_present && !do_fill, ...) +
    ggplot2::scale_colour_manual(values = colors, name = v$names$hue)
  if (!hue_present) p <- p + ggplot2::guides(colour = "none", fill = "none")

  count_expand <- ggplot2::expansion(mult = c(0, 0.05))
  if (horizontal) {
    p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks(), expand = count_expand) +
      ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
  } else {
    p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
      ggplot2::scale_y_continuous(breaks = rb_mpl_breaks(), expand = count_expand)
  }

  dens_lab <- if (cumulative) "Proportion" else "Density"
  ld <- if (horizontal) list(x = curves$y, y = curves$x) else list(x = curves$x, y = curves$y)
  p <- rb_finish_plot(p, xlab = if (horizontal) dens_lab else v$names$val,
                      ylab = if (horizontal) v$names$val else dens_lab,
                      legend = if (isFALSE(legend)) FALSE else "auto",
                      legend_data = ld, any_legend = hue_present, breaks = FALSE)
  reaborn_plot(p, call = match.call())
}

# Stack / fill KDE curves on a shared grid.
rb_kde_stack <- function(curves, multiple, levels) {
  wide <- split(curves, curves$group)
  grid <- wide[[1]]$x
  mat <- vapply(levels, function(g) {
    sub <- wide[[g]]; stats::approx(sub$x, sub$y, grid, rule = 2)$y
  }, numeric(length(grid)))
  cum <- t(apply(mat, 1, cumsum))
  if (multiple == "fill") {
    tot <- cum[, ncol(cum)]; tot[tot == 0] <- 1e-9
    cum <- cum / tot
  }
  do.call(rbind, lapply(seq_along(levels), function(i) {
    data.frame(group = levels[i], x = grid, y = cum[, i], stringsAsFactors = FALSE)
  }))
}

# Bivariate KDE contour plot using a scipy-matching 2-D Gaussian KDE and
# iso-proportion contour levels.
rb_kdeplot_bivariate <- function(data, x, y, hue, palette, hue_order, color, fill,
                                 levels, thresh, bw_adjust, gridsize, cut, legend, ...) {
  v <- rb_assign_variables(data, x = x, y = y, hue = hue)
  mb <- rb_make_base(data, v, c("x", "y", "hue"))
  vd <- mb$vd
  dens <- rb_gaussian_kde_2d(vd[["x"]], vd[["y"]], bw_adjust, gridsize, cut)
  lev <- rb_iso_proportion_levels(dens$z, if (length(levels) == 1) levels else levels, thresh)
  col <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)
  grid_df <- expand.grid(x = dens$x, y = dens$y)
  grid_df$z <- as.vector(dens$z)
  do_fill <- isTRUE(fill)
  p <- ggplot2::ggplot(grid_df, ggplot2::aes(x = .data$x, y = .data$y, z = .data$z))
  if (do_fill) {
    cmap <- attr(light_palette(col, as_cmap = TRUE), "colors")
    p <- p + ggplot2::geom_contour_filled(breaks = c(lev, Inf)) +
      ggplot2::scale_fill_manual(values = cmap[round(seq(40, 256, length.out = length(lev)))],
                                 guide = "none")
  } else {
    p <- p + ggplot2::geom_contour(breaks = lev, colour = col,
                                   linewidth = rb_line_default_width())
  }
  p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
    ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
  p <- rb_finish_plot(p, xlab = v$names$x, ylab = v$names$y, legend = FALSE)
  reaborn_plot(p, call = match.call())
}

# 2-D Gaussian KDE matching scipy.stats.gaussian_kde (full covariance).
rb_gaussian_kde_2d <- function(x, y, bw_adjust = 1, gridsize = 100, cut = 3) {
  ok <- !is.na(x) & !is.na(y)
  x <- x[ok]; y <- y[ok]
  n <- length(x)
  d <- 2
  factor <- n^(-1 / (d + 4)) * bw_adjust
  cov <- stats::cov(cbind(x, y))                 # ddof = 1
  H <- factor^2 * cov
  Hinv <- solve(H)
  detH <- det(H)
  bwx <- sqrt(H[1, 1]); bwy <- sqrt(H[2, 2])
  gx <- seq(min(x) - cut * bwx, max(x) + cut * bwx, length.out = gridsize)
  gy <- seq(min(y) - cut * bwy, max(y) + cut * bwy, length.out = gridsize)
  norm <- 1 / (n * 2 * pi * sqrt(detH))
  z <- matrix(0, gridsize, gridsize)
  for (j in seq_len(gridsize)) {
    for (k in seq_len(gridsize)) {
      ddx <- gx[j] - x; ddy <- gy[k] - y
      m <- Hinv[1, 1] * ddx^2 + 2 * Hinv[1, 2] * ddx * ddy + Hinv[2, 2] * ddy^2
      z[j, k] <- norm * sum(exp(-0.5 * m))
    }
  }
  list(x = gx, y = gy, z = z)
}

# Convert iso-proportion levels (fraction of mass enclosed) to density levels,
# mirroring seaborn's _quantile_to_level.
rb_iso_proportion_levels <- function(z, levels, thresh = 0.05) {
  if (length(levels) == 1) {
    levels <- seq(thresh, 1, length.out = levels)
  }
  v <- sort(as.vector(z), decreasing = TRUE)
  csum <- cumsum(v) / sum(v)
  vapply(levels, function(p) {
    idx <- which(csum >= p)[1]
    if (is.na(idx)) min(v) else v[idx]
  }, numeric(1))
}

#' Plot an empirical cumulative distribution function
#'
#' Port of `seaborn.ecdfplot`. Returns a [reaborn_plot].
#'
#' @inheritParams histplot
#' @param stat `"proportion"`, `"count"`, or `"percent"`.
#' @param complementary Plot the complementary ECDF (1 - F).
#' @return A `reaborn_plot`.
#' @param palette Palette for the hue mapping.
#' @param hue_order Order of hue levels.
#' @param hue_norm Normalization for a numeric hue.
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @export
ecdfplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, weights = NULL,
                     stat = "proportion", complementary = FALSE, palette = NULL,
                     hue_order = NULL, hue_norm = NULL, legend = TRUE,
                     .facet_vars = NULL, ...) {
  horizontal <- is.null(x) && !is.null(y)
  vvar <- if (horizontal) y else x
  v <- rb_assign_variables(data, val = vvar, hue = hue, weights = weights)
  mb <- rb_make_base(data, v, c("val", "hue", "weights"))
  vd <- mb$vd
  vals <- vd[["val"]]

  hue_present <- "hue" %in% names(vd)
  if (hue_present) {
    lv <- rb_categorical_order(vd[["hue"]], hue_order)
    groups <- factor(as.character(vd[["hue"]]), levels = lv)
    colors <- stats::setNames(rb_categorical_colors(length(lv), palette), lv)
  } else {
    lv <- "_all"; groups <- factor(rep("_all", length(vals)))
    colors <- stats::setNames(color_palette(.reaborn_get("palette", "deep"), 1), lv)
  }

  facet_vars <- intersect(.facet_vars %||% character(0), names(mb$base))
  work <- data.frame(.val = vals, .group = groups, stringsAsFactors = FALSE)
  for (fv in facet_vars) work[[fv]] <- mb$base[[fv]]
  combos <- unique(work[c(".group", facet_vars)])
  curves <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
    sel <- work$.group == combos$.group[i]
    for (fv in facet_vars) sel <- sel & as.character(work[[fv]]) == as.character(combos[i, fv])
    gx <- sort(work$.val[sel])
    n <- length(gx)
    if (!n) return(NULL)
    yy <- seq_len(n) / n
    if (stat == "count") yy <- seq_len(n)
    else if (stat == "percent") yy <- yy * 100
    top <- if (stat == "count") n else if (stat == "percent") 100 else 1
    if (complementary) yy <- top - yy
    base_y <- if (complementary) top else 0
    row <- data.frame(group = combos$.group[i], x = c(gx[1], gx),
                      y = c(base_y, yy), stringsAsFactors = FALSE)
    for (fv in facet_vars) row[[fv]] <- combos[i, fv]
    row
  }))
  curves$group <- factor(curves$group, levels = lv)

  aes_step <- if (horizontal) {
    ggplot2::aes(x = .data$y, y = .data$x, colour = .data$group, group = .data$group)
  } else {
    ggplot2::aes(x = .data$x, y = .data$y, colour = .data$group, group = .data$group)
  }
  p <- ggplot2::ggplot(curves) +
    ggplot2::geom_step(aes_step, direction = "hv",
                       linewidth = rb_line_default_width(), show.legend = hue_present, ...) +
    ggplot2::scale_colour_manual(values = colors, name = v$names$hue)
  if (!hue_present) p <- p + ggplot2::guides(colour = "none")

  lab <- switch(stat, proportion = "Proportion", count = "Count", percent = "Percent", stat)
  ld <- if (horizontal) list(x = curves$y, y = curves$x) else list(x = curves$x, y = curves$y)
  p <- rb_finish_plot(p, xlab = if (horizontal) lab else v$names$val,
                      ylab = if (horizontal) v$names$val else lab,
                      legend = if (isFALSE(legend)) FALSE else "auto",
                      legend_data = ld, any_legend = hue_present)
  reaborn_plot(p, call = match.call())
}

#' Plot marginal rug ticks
#'
#' Port of `seaborn.rugplot`. Draws small ticks at each observation along the
#' relevant axis. Returns a [reaborn_plot] (typically added to another plot, but
#' usable standalone).
#'
#' @inheritParams histplot
#' @param height Tick height as a fraction of the axis (default `0.025`).
#' @param expand_margins Reserved for compatibility.
#' @return A `reaborn_plot`.
#' @param palette Palette for the hue mapping.
#' @param hue_order Order of hue levels.
#' @param hue_norm Normalization for a numeric hue.
#' @export
rugplot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, height = 0.025,
                    expand_margins = TRUE, palette = NULL, hue_order = NULL,
                    hue_norm = NULL, legend = TRUE, ...) {
  v <- rb_assign_variables(data, x = x, y = y, hue = hue)
  mb <- rb_make_base(data, v, c("x", "y", "hue"))
  base <- mb$base; vd <- mb$vd
  hue_present <- "hue" %in% names(vd)

  mapping <- ggplot2::aes()
  if ("x" %in% names(vd)) { base$`__x` <- vd$x; mapping$x <- rlang::sym("__x") }
  if ("y" %in% names(vd)) { base$`__y` <- vd$y; mapping$y <- rlang::sym("__y") }
  sides <- paste0(if ("x" %in% names(vd)) "b" else "", if ("y" %in% names(vd)) "l" else "")
  colors <- NULL
  if (hue_present) {
    lv <- rb_categorical_order(vd[["hue"]], hue_order)
    base$`__hue` <- factor(as.character(vd[["hue"]]), levels = lv)
    mapping$colour <- rlang::sym("__hue")
    colors <- stats::setNames(rb_categorical_colors(length(lv), palette), lv)
  }
  rug_args <- list(mapping = mapping, sides = sides,
                   length = grid::unit(height, "npc"), ...)
  if (!hue_present) rug_args$colour <- color_palette(.reaborn_get("palette", "deep"), 1)
  p <- ggplot2::ggplot(base) + do.call(ggplot2::geom_rug, rug_args)
  if (hue_present) p <- p + ggplot2::scale_colour_manual(values = colors, name = v$names$hue)
  p <- rb_finish_plot(p, xlab = v$names$x, ylab = v$names$y,
                      legend = if (isFALSE(legend)) FALSE else "auto")
  reaborn_plot(p, call = match.call())
}

#' Figure-level interface for distribution plots
#'
#' Port of `seaborn.displot`. Draws [histplot] (`kind = "hist"`), [kdeplot]
#' (`kind = "kde"`), or [ecdfplot] (`kind = "ecdf"`) onto a grid of facets.
#' Returns a faceted [reaborn_plot].
#'
#' @inheritParams histplot
#' @param row,col,col_wrap,row_order,col_order Faceting controls.
#' @param kind `"hist"`, `"kde"`, or `"ecdf"`.
#' @param rug Add a marginal rug.
#' @param height,aspect Facet size controls (stored as attributes).
#' @param facet_kws Reserved for compatibility.
#' @return A `reaborn_plot`.
#' @param rug_kws Arguments forwarded to the rug layer when `rug = TRUE`.
#' @export
displot <- function(data = NULL, x = NULL, y = NULL, hue = NULL, row = NULL,
                    col = NULL, weights = NULL, kind = "hist", rug = FALSE,
                    rug_kws = NULL, palette = NULL, hue_order = NULL, hue_norm = NULL,
                    color = NULL, col_wrap = NULL, row_order = NULL, col_order = NULL,
                    legend = TRUE, height = 5, aspect = 1, facet_kws = NULL, ...) {
  base_fun <- switch(kind, hist = histplot, kde = kdeplot, ecdf = ecdfplot,
                     stop(sprintf("kind must be 'hist', 'kde', or 'ecdf', not '%s'", kind)))
  args <- list(data = data, x = x, y = y, hue = hue, palette = palette,
               hue_order = hue_order, hue_norm = hue_norm, legend = legend,
               .facet_vars = c(row, col), ...)
  if (kind != "ecdf") args$weights <- weights
  p <- do.call(base_fun, args)
  p <- rb_facet(p, data, row, col, col_wrap, row_order, col_order)
  if (!is.null(row) || !is.null(col)) {
    p <- p + ggplot2::theme(legend.position = "right")
  }
  attr(p, "rb_height") <- height
  attr(p, "rb_aspect") <- aspect
  reaborn_plot(p, call = match.call())
}
