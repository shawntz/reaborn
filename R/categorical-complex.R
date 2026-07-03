# The hard categorical families: violinplot, boxenplot, swarmplot. These need
# custom statistics (KDE-based violins, letter-value boxes, beeswarm packing)
# that ggplot2's built-in geoms do not reproduce faithfully, so reaborn computes
# them itself and draws with primitive geoms.

# Group a categorical setup into (cat, hue) subsets, returning for each: the
# values, the continuous category position (1..n), the dodge offset, the half
# width available, and the fill color.
.rb_violin_groups <- function(s, width, gap) {
  cat_levels <- s$cat_levels
  hue_levels <- if (s$has_hue) s$hue_levels else "_all"
  n_hue <- length(hue_levels)
  sub_w <- width / n_hue * (1 - gap)
  fvars <- s$facet_vars %||% character(0)
  fcombos <- if (length(fvars)) unique(s$df[fvars]) else data.frame(.d = 1)
  groups <- list()
  for (fi in seq_len(nrow(fcombos))) {
    fsel <- rep(TRUE, nrow(s$df))
    for (fv in fvars) {
      fsel <- fsel & as.character(s$df[[fv]]) == as.character(fcombos[fi, fv])
    }
    facets <- if (length(fvars)) fcombos[fi, fvars, drop = FALSE] else NULL
    for (ci in seq_along(cat_levels)) {
      for (hi in seq_along(hue_levels)) {
        lv <- cat_levels[ci]
        sel <- fsel & as.character(s$df$.cat) == lv
        if (s$has_hue) {
          sel <- sel & as.character(s$df$.hue) == hue_levels[hi]
        }
        vals <- s$df$.val[sel]
        vals <- vals[!is.na(vals)]
        offset <- if (s$has_hue) (hi - (n_hue + 1) / 2) * (width / n_hue) else 0
        groups[[length(groups) + 1]] <- list(
          cat = lv,
          hue = hue_levels[hi],
          hue_idx = hi,
          pos = ci + offset,
          vals = vals,
          half = sub_w / 2,
          facets = facets
        )
      }
    }
  }
  groups
}

# Attach a group's facet column values to every row of a data frame.
.rb_attach_facets <- function(df, g) {
  if (!is.null(g$facets)) {
    for (fv in names(g$facets)) {
      df[[fv]] <- g$facets[[1, fv]]
    }
  }
  df
}

#' Draw a violin plot
#'
#' Port of `seaborn.violinplot`. The kernel density matches
#' `scipy.stats.gaussian_kde`. Returns a [reaborn_plot].
#'
#' @inheritParams boxplot
#' @param inner `"box"`, `"quart"`, `"stick"`, `"point"`, or `NULL`.
#' @param split Draw split violins for two hue levels.
#' @param cut,gridsize,bw_method,bw_adjust KDE controls.
#' @param density_norm `"area"`, `"count"`, or `"width"`.
#' @param common_norm Normalize densities across all groups together.
#' @param inner_kws Passed to the inner annotation geoms.
#' @return A `reaborn_plot`.
#' @param dodge How to dodge violins by hue (`"auto"`, `TRUE`, or `FALSE`).
#' @param linewidth Outline width.
#' @param linecolor Outline color (`"auto"` for seaborn's gray).
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @examples
#' tips <- load_dataset("tips")
#' violinplot(data = tips, x = "day", y = "total_bill")
#' violinplot(data = tips, x = "day", y = "total_bill", hue = "sex", split = TRUE)
#' @export
violinplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  order = NULL,
  hue_order = NULL,
  orient = NULL,
  color = NULL,
  palette = NULL,
  saturation = 0.75,
  fill = TRUE,
  inner = "box",
  split = FALSE,
  width = 0.8,
  dodge = "auto",
  gap = 0,
  linewidth = NULL,
  linecolor = "auto",
  cut = 2,
  gridsize = 100,
  bw_method = "scott",
  bw_adjust = 1,
  density_norm = "area",
  common_norm = FALSE,
  legend = "auto",
  inner_kws = NULL,
  .facet_vars = NULL,
  ...
) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  vert <- s$orient == "v"
  colors <- rb_cat_colors(s, palette, color, saturation)
  groups <- .rb_violin_groups(s, width, gap)
  lc <- if (identical(linecolor, "auto")) RB_BOX_LINECOLOR else linecolor
  lw <- .rb_lw(linewidth %||% 1.25)

  # KDE per group + density normalization.
  for (i in seq_along(groups)) {
    g <- groups[[i]]
    if (length(g$vals) < 2) {
      groups[[i]]$kde <- NULL
      next
    }
    groups[[i]]$kde <- rb_gaussian_kde(
      g$vals,
      bw_method,
      bw_adjust,
      gridsize,
      cut
    )
    groups[[i]]$n <- length(g$vals)
  }
  valid <- Filter(function(g) !is.null(g$kde), groups)
  max_dens <- max(vapply(valid, function(g) max(g$kde$y), numeric(1)))
  max_n <- max(vapply(valid, function(g) g$n, numeric(1)))

  polys <- list()
  inner_segs <- list()
  inner_pts <- list()
  pi <- 0
  for (g in groups) {
    if (is.null(g$kde)) {
      next
    }
    pi <- pi + 1
    dens <- g$kde$y
    scale <- switch(
      density_norm,
      area = g$half / max_dens,
      count = g$half / max_dens * (g$n / max_n),
      width = g$half / max(dens),
      g$half / max_dens
    )
    w <- dens * scale
    grid <- g$kde$x
    is_split <- isTRUE(split) && s$has_hue && length(s$hue_levels) == 2
    if (is_split) {
      side <- if (g$hue_idx == 1) -1 else 1
      pos_lo <- if (side < 0) g$pos - w else rep(g$pos, length(w))
      pos_hi <- if (side < 0) rep(g$pos, length(w)) else g$pos + w
      px <- c(g$pos + 0 * w, rev(g$pos + side * w))
      py <- c(grid, rev(grid))
      # adjust to center the pair at the category
      px <- c(rep(g$pos, length(w)), rev(g$pos + side * w))
    } else {
      px <- c(g$pos - w, rev(g$pos + w))
      py <- c(grid, rev(grid))
    }
    polys[[pi]] <- .rb_attach_facets(
      data.frame(
        id = pi,
        x = px,
        y = py,
        fill = g$hue,
        stringsAsFactors = FALSE
      ),
      g
    )

    # Inner annotations.
    if (!is.null(inner) && !isFALSE(inner)) {
      q <- stats::quantile(g$vals, c(0.25, 0.5, 0.75), names = FALSE, type = 7)
      iqr <- q[3] - q[1]
      lo <- max(min(g$vals), q[1] - 1.5 * iqr)
      hi <- min(max(g$vals), q[3] + 1.5 * iqr)
      af <- function(df) .rb_attach_facets(df, g)
      if (inner == "box") {
        inner_segs[[length(inner_segs) + 1]] <- af(data.frame(
          pos = g$pos,
          ylo = q[1],
          yhi = q[3],
          lw = "thick"
        ))
        inner_segs[[length(inner_segs) + 1]] <- af(data.frame(
          pos = g$pos,
          ylo = lo,
          yhi = hi,
          lw = "thin"
        ))
        inner_pts[[length(inner_pts) + 1]] <- af(data.frame(
          pos = g$pos,
          y = q[2]
        ))
      } else if (inner == "quart") {
        for (qq in q) {
          inner_segs[[length(inner_segs) + 1]] <- af(data.frame(
            pos = g$pos,
            ylo = qq,
            yhi = qq,
            lw = "quart",
            xmin = g$pos - max(w),
            xmax = g$pos + max(w)
          ))
        }
      } else if (inner == "stick") {
        for (vv in g$vals) {
          inner_segs[[length(inner_segs) + 1]] <- af(data.frame(
            pos = g$pos,
            ylo = vv,
            yhi = vv,
            lw = "stick"
          ))
        }
      } else if (inner == "point") {
        for (vv in g$vals) {
          inner_pts[[length(inner_pts) + 1]] <- af(data.frame(
            pos = g$pos,
            y = vv
          ))
        }
      }
    }
  }
  poly_df <- do.call(rbind, polys)

  flip <- function(df, xcol, ycol) {
    if (vert) {
      df
    } else {
      tmp <- df[[xcol]]
      df[[xcol]] <- df[[ycol]]
      df[[ycol]] <- tmp
      df
    }
  }

  pmap <- if (vert) {
    ggplot2::aes(x = .data$x, y = .data$y, group = .data$id)
  } else {
    ggplot2::aes(x = .data$y, y = .data$x, group = .data$id)
  }
  if (s$has_hue) {
    pmap$fill <- rlang::sym("fill")
  }
  poly_args <- list(mapping = pmap, colour = lc, linewidth = lw)
  if (!s$has_hue) {
    poly_args$fill <- colors
  }
  p <- ggplot2::ggplot(poly_df) + do.call(ggplot2::geom_polygon, poly_args)

  # Inner box / quart / stick / point.
  if (length(inner_segs)) {
    seg <- do.call(
      rbind,
      lapply(inner_segs, function(d) {
        d$lwval <- d$lw[1]
        d
      })
    )
    for (kind in unique(seg$lw)) {
      sub <- seg[seg$lw == kind, ]
      thick <- switch(
        kind,
        thick = .rb_lw(6),
        thin = .rb_lw(1.5),
        quart = .rb_lw(1.5),
        stick = .rb_lw(1),
        .rb_lw(1.5)
      )
      seg_aes <- if (vert) {
        ggplot2::aes(
          x = .data$pos,
          xend = .data$pos,
          y = .data$ylo,
          yend = .data$yhi
        )
      } else {
        ggplot2::aes(
          y = .data$pos,
          yend = .data$pos,
          x = .data$ylo,
          xend = .data$yhi
        )
      }
      p <- p +
        ggplot2::geom_segment(
          data = sub,
          mapping = seg_aes,
          colour = if (kind == "stick") "white" else RB_BOX_LINECOLOR,
          linewidth = thick,
          lineend = "round"
        )
    }
  }
  if (length(inner_pts)) {
    pts <- do.call(rbind, inner_pts)
    pt_aes <- if (vert) {
      ggplot2::aes(x = .data$pos, y = .data$y)
    } else {
      ggplot2::aes(x = .data$y, y = .data$pos)
    }
    p <- p +
      ggplot2::geom_point(
        data = pts,
        mapping = pt_aes,
        colour = "white",
        fill = "white",
        size = rb_area_to_size(9)
      )
  }

  if (s$has_hue) {
    p <- p + ggplot2::scale_fill_manual(values = colors, name = s$hue_name)
  }

  # Category axis with continuous positions labelled by level.
  cat_scale <- if (vert) {
    ggplot2::scale_x_continuous
  } else {
    ggplot2::scale_y_continuous
  }
  val_scale <- if (vert) {
    ggplot2::scale_y_continuous
  } else {
    ggplot2::scale_x_continuous
  }
  p <- p +
    cat_scale(breaks = seq_along(s$cat_levels), labels = s$cat_levels) +
    val_scale(breaks = rb_mpl_breaks())
  xlab <- if (vert) s$cat_name else s$val_name
  ylab <- if (vert) s$val_name else s$cat_name
  p <- rb_finish_plot(
    p,
    xlab = xlab,
    ylab = ylab,
    legend = if (isFALSE(legend)) FALSE else "auto",
    breaks = FALSE
  )
  if (s$has_hue && !isFALSE(legend)) {
    p <- p + rb_legend_right()
  }
  reaborn_plot(p, call = match.call())
}

# Number of letter-value boxes (LetterValues._compute_k).
.rb_lv_k <- function(
  n,
  k_depth = "tukey",
  outlier_prop = 0.007,
  trust_alpha = 0.05
) {
  k <- if (is.numeric(k_depth)) {
    as.integer(k_depth)
  } else {
    switch(
      k_depth,
      full = as.integer(log2(n)) + 1,
      tukey = as.integer(log2(n)) - 3,
      proportion = as.integer(log2(n)) - as.integer(log2(n * outlier_prop)) + 1,
      trustworthy = {
        point_conf <- 2 * stats::qnorm(1 - trust_alpha / 2)^2
        as.integer(log2(n / point_conf)) + 1
      },
      as.integer(log2(n)) - 3
    )
  }
  max(k, 1)
}

# Letter values for a vector (port of LetterValues.__call__).
rb_letter_values <- function(
  x,
  k_depth = "tukey",
  outlier_prop = 0.007,
  trust_alpha = 0.05
) {
  x <- x[!is.na(x)]
  n <- length(x)
  k <- .rb_lv_k(n, k_depth, outlier_prop, trust_alpha)
  exp0 <- seq(k + 1, 2) # k+1 .. 2
  exp1 <- seq(2, k + 1) # 2 .. k+1
  levels <- (k + 1) - c(exp0, exp1[-1])
  percs <- 100 * c(0.5^exp0, 1 - 0.5^exp1)
  if (identical(k_depth, "full")) {
    percs[1] <- 0
    percs[length(percs)] <- 100
  }
  values <- stats::quantile(x, percs / 100, names = FALSE, type = 7)
  fliers <- x[x < min(values) | x > max(values)]
  list(
    k = k,
    levels = levels,
    percs = percs,
    values = values,
    fliers = fliers,
    median = stats::quantile(x, 0.5, names = FALSE, type = 7)
  )
}

#' Draw an enhanced box plot for larger datasets
#'
#' Port of `seaborn.boxenplot` (letter-value plot). Returns a [reaborn_plot].
#'
#' @inheritParams boxplot
#' @param width_method `"exponential"`, `"linear"`, or `"area"`.
#' @param k_depth `"tukey"`, `"proportion"`, `"trustworthy"`, `"full"`, or an int.
#' @param outlier_prop,trust_alpha Tail-rule parameters.
#' @param showfliers Draw outlier points.
#' @return A `reaborn_plot`.
#' @param linewidth Box outline width.
#' @param linecolor Box outline color.
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @examples
#' tips <- load_dataset("tips")
#' boxenplot(data = tips, x = "day", y = "total_bill")
#' boxenplot(data = tips, x = "day", y = "total_bill", hue = "smoker")
#' @export
boxenplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  order = NULL,
  hue_order = NULL,
  orient = NULL,
  color = NULL,
  palette = NULL,
  saturation = 0.75,
  fill = TRUE,
  width = 0.8,
  gap = 0,
  linewidth = NULL,
  linecolor = NULL,
  width_method = "exponential",
  k_depth = "tukey",
  outlier_prop = 0.007,
  trust_alpha = 0.05,
  showfliers = TRUE,
  legend = "auto",
  .facet_vars = NULL,
  ...
) {
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  vert <- s$orient == "v"
  base_colors <- rb_cat_colors(s, palette, color, 1) # boxen uses light gradient, not desat
  hue_levels <- if (s$has_hue) s$hue_levels else "_all"
  lc <- linecolor %||% "white"
  lw <- .rb_lw(linewidth %||% 0.5)
  groups <- .rb_violin_groups(s, width, gap)

  boxes <- list()
  meds <- list()
  fliers <- list()
  for (g in groups) {
    if (length(g$vals) < 2) {
      next
    }
    maincolor <- if (s$has_hue) base_colors[[g$hue]] else base_colors[1]
    lv <- rb_letter_values(g$vals, k_depth, outlier_prop, trust_alpha)
    vals <- lv$values
    nbox <- length(vals) - 1
    exponent <- lv$levels - 1 - lv$k
    rel <- switch(
      width_method,
      linear = lv$levels + 1,
      exponential = 2^exponent,
      area = {
        tails <- lv$levels < (lv$k - 1)
        2^(exponent - tails) / diff(vals)
      },
      2^exponent
    )
    widths <- rel / max(rel) * (2 * g$half)
    cmap <- light_palette(maincolor, as_cmap = TRUE)
    boxcolors <- cmap(2^((exponent + 2) / 3))
    for (i in seq_len(nbox)) {
      boxes[[length(boxes) + 1]] <- .rb_attach_facets(
        data.frame(
          xmin = g$pos - widths[i] / 2,
          xmax = g$pos + widths[i] / 2,
          ymin = vals[i],
          ymax = vals[i + 1],
          fillcol = boxcolors[i],
          stringsAsFactors = FALSE
        ),
        g
      )
    }
    meds[[length(meds) + 1]] <- .rb_attach_facets(
      data.frame(
        pos = g$pos,
        y = lv$median,
        xmin = g$pos - max(widths) / 2,
        xmax = g$pos + max(widths) / 2
      ),
      g
    )
    if (showfliers && length(lv$fliers)) {
      fliers[[length(fliers) + 1]] <- .rb_attach_facets(
        data.frame(pos = g$pos, y = lv$fliers),
        g
      )
    }
  }
  box_df <- do.call(rbind, boxes)

  rect_aes <- if (vert) {
    ggplot2::aes(
      xmin = .data$xmin,
      xmax = .data$xmax,
      ymin = .data$ymin,
      ymax = .data$ymax
    )
  } else {
    ggplot2::aes(
      ymin = .data$xmin,
      ymax = .data$xmax,
      xmin = .data$ymin,
      xmax = .data$ymax
    )
  }
  p <- ggplot2::ggplot(box_df) +
    ggplot2::geom_rect(
      rect_aes,
      fill = box_df$fillcol,
      colour = lc,
      linewidth = lw
    )

  # Median line (across the widest box).
  med_df <- do.call(rbind, meds)
  med_aes <- if (vert) {
    ggplot2::aes(x = .data$xmin, xend = .data$xmax, y = .data$y, yend = .data$y)
  } else {
    ggplot2::aes(y = .data$xmin, yend = .data$xmax, x = .data$y, xend = .data$y)
  }
  p <- p +
    ggplot2::geom_segment(
      data = med_df,
      mapping = med_aes,
      colour = "#262626",
      linewidth = .rb_lw(1.5)
    )

  if (length(fliers)) {
    fl_df <- do.call(rbind, fliers)
    fl_aes <- if (vert) {
      ggplot2::aes(x = .data$pos, y = .data$y)
    } else {
      ggplot2::aes(x = .data$y, y = .data$pos)
    }
    p <- p +
      ggplot2::geom_point(
        data = fl_df,
        mapping = fl_aes,
        shape = 1,
        colour = "#737373",
        size = 1.5,
        stroke = .rb_lw(1)
      )
  }

  cat_scale <- if (vert) {
    ggplot2::scale_x_continuous
  } else {
    ggplot2::scale_y_continuous
  }
  val_scale <- if (vert) {
    ggplot2::scale_y_continuous
  } else {
    ggplot2::scale_x_continuous
  }
  p <- p +
    cat_scale(breaks = seq_along(s$cat_levels), labels = s$cat_levels) +
    val_scale(breaks = rb_mpl_breaks())
  xlab <- if (vert) s$cat_name else s$val_name
  ylab <- if (vert) s$val_name else s$cat_name
  p <- rb_finish_plot(
    p,
    xlab = xlab,
    ylab = ylab,
    legend = if (isFALSE(legend)) FALSE else "auto",
    breaks = FALSE
  )
  reaborn_plot(p, call = match.call())
}

#' Draw a categorical scatter with non-overlapping points
#'
#' Port of `seaborn.swarmplot`, using a beeswarm layout. Returns a [reaborn_plot].
#'
#' @inheritParams stripplot
#' @param ... Passed to [ggbeeswarm::geom_beeswarm].
#' @return A `reaborn_plot`.
#' @param color Single color override.
#' @param palette Palette for the hue mapping.
#' @param .facet_vars Internal; facet columns forwarded by the figure-level dispatchers (catplot/displot/relplot). Not intended for direct use.
#' @examplesIf requireNamespace("ggbeeswarm", quietly = TRUE)
#' tips <- load_dataset("tips")
#' swarmplot(data = tips, x = "day", y = "total_bill")
#' swarmplot(data = tips, x = "day", y = "total_bill", hue = "sex", dodge = TRUE)
#' @export
swarmplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  order = NULL,
  hue_order = NULL,
  dodge = FALSE,
  orient = NULL,
  color = NULL,
  palette = NULL,
  size = 5,
  edgecolor = NULL,
  linewidth = 0,
  legend = "auto",
  .facet_vars = NULL,
  ...
) {
  if (!requireNamespace("ggbeeswarm", quietly = TRUE)) {
    stop(
      "swarmplot() requires the 'ggbeeswarm' package. Install it with install.packages('ggbeeswarm')."
    )
  }
  s <- rb_cat_setup(data, x, y, hue, order, hue_order, orient, .facet_vars)
  vert <- s$orient == "v"
  if (s$has_hue) {
    colors <- stats::setNames(
      rb_categorical_colors(length(s$hue_levels), palette),
      s$hue_levels
    )
  } else {
    colors <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)
  }
  pt_aes <- if (vert) {
    ggplot2::aes(x = .data$.cat, y = .data$.val)
  } else {
    ggplot2::aes(x = .data$.val, y = .data$.cat)
  }
  if (s$has_hue) {
    pt_aes$colour <- rlang::sym(".hue")
  }
  sw_args <- list(
    pt_aes,
    size = rb_area_to_size(size^2),
    stroke = linewidth,
    cex = 2.2,
    ...
  )
  if (isTRUE(dodge) && s$has_hue) {
    sw_args$dodge.width <- 0.8
  }
  if (!s$has_hue) {
    sw_args$colour <- colors
  }
  p <- ggplot2::ggplot(s$df) + do.call(ggbeeswarm::geom_beeswarm, sw_args)
  if (s$has_hue) {
    p <- p + ggplot2::scale_colour_manual(values = colors, name = s$hue_name)
  }
  p <- rb_cat_finish(p, s, legend)
  reaborn_plot(p, call = match.call())
}
