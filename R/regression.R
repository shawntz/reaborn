# Regression plots: regplot, residplot, lmplot. Ports of seaborn/regression.py.
# The regression line and its confidence band are computed with an explicit
# bootstrap (resample -> refit -> predict on a grid -> percentile band), matching
# seaborn, rather than ggplot2's analytic stat_smooth standard error.

# Fit a model and predict on a grid for one (x, y) sample.
.rb_reg_fit <- function(
  x,
  y,
  grid,
  order = 1,
  logistic = FALSE,
  lowess = FALSE,
  robust = FALSE,
  logx = FALSE
) {
  if (lowess) {
    lo <- stats::lowess(x, y, f = 2 / 3)
    return(stats::approx(lo$x, lo$y, grid, rule = 2)$y)
  }
  if (logistic) {
    fit <- suppressWarnings(stats::glm(y ~ x, family = stats::binomial()))
    return(stats::predict(fit, data.frame(x = grid), type = "response"))
  }
  if (logx) {
    fit <- stats::lm(y ~ log(x))
    return(stats::predict(fit, data.frame(x = grid)))
  }
  if (robust) {
    if (!requireNamespace("MASS", quietly = TRUE)) {
      fit <- stats::lm(y ~ x)
    } else {
      fit <- MASS::rlm(y ~ x)
    }
    return(stats::predict(fit, data.frame(x = grid)))
  }
  fit <- stats::lm(y ~ stats::poly(x, order, raw = TRUE))
  as.numeric(stats::predict(fit, data.frame(x = grid)))
}

# Bootstrap confidence band for the regression line.
.rb_reg_band <- function(x, y, grid, ci, n_boot, seed, ...) {
  if (is.null(ci)) {
    return(NULL)
  }
  if (!is.null(seed)) {
    set.seed(seed)
  }
  n <- length(x)
  boots <- vapply(
    seq_len(n_boot),
    function(i) {
      idx <- sample.int(n, n, replace = TRUE)
      tryCatch(.rb_reg_fit(x[idx], y[idx], grid, ...), error = function(e) {
        rep(NA_real_, length(grid))
      })
    },
    numeric(length(grid))
  )
  edge <- (100 - ci) / 2
  data.frame(
    grid = grid,
    lo = apply(boots, 1, stats::quantile, probs = edge / 100, na.rm = TRUE),
    hi = apply(boots, 1, stats::quantile, probs = 1 - edge / 100, na.rm = TRUE)
  )
}

#' Plot data and a linear regression model fit
#'
#' Port of `seaborn.regplot`. The confidence band is a bootstrap interval, like
#' seaborn. Returns a [reaborn_plot].
#'
#' @param data A data frame.
#' @param x,y Variables.
#' @param order Polynomial order for the fit (default 1, linear).
#' @param logistic,lowess,robust,logx Alternative fits.
#' @param ci Confidence-band width (default 95; `NULL` to omit).
#' @param n_boot,seed Bootstrap settings.
#' @param scatter,fit_reg Whether to draw the scatter / the fit.
#' @param color Color for points and line (default the first palette color).
#' @param marker Marker (accepted for compatibility).
#' @param scatter_kws,line_kws Lists of extra args for the point / line layers.
#' @param truncate Limit the regression line to the data range.
#' @param ... Reserved.
#' @return A `reaborn_plot`.
#' @param x_jitter Uniform jitter added to x for display only.
#' @param y_jitter Uniform jitter added to y for display only.
#' @examples
#' tips <- load_dataset("tips")
#' regplot(data = tips, x = "total_bill", y = "tip")
#'
#' # Fit a higher-order polynomial
#' regplot(data = tips, x = "size", y = "total_bill", order = 2)
#' @export
regplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  order = 1,
  logistic = FALSE,
  lowess = FALSE,
  robust = FALSE,
  logx = FALSE,
  ci = 95,
  n_boot = 1000,
  seed = NULL,
  scatter = TRUE,
  fit_reg = TRUE,
  color = NULL,
  marker = "o",
  scatter_kws = NULL,
  line_kws = NULL,
  truncate = TRUE,
  x_jitter = NULL,
  y_jitter = NULL,
  ...
) {
  v <- rb_assign_variables(data, x = x, y = y)
  df <- rb_drop_na(v$data, c("x", "y"))
  xv <- df$x
  yv <- df$y
  col <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$x, y = .data$y))

  if (scatter) {
    sk <- scatter_kws %||% list()
    p <- p +
      ggplot2::geom_point(
        colour = sk$color %||% col,
        fill = sk$color %||% col,
        size = sk$size %||% rb_area_to_size(36),
        shape = 21,
        stroke = 0,
        alpha = sk$alpha %||% 1
      )
  }

  if (fit_reg) {
    grid <- seq(min(xv), max(xv), length.out = 100)
    yhat <- .rb_reg_fit(
      xv,
      yv,
      grid,
      order = order,
      logistic = logistic,
      lowess = lowess,
      robust = robust,
      logx = logx
    )
    fit_df <- data.frame(grid = grid, yhat = yhat)
    band <- .rb_reg_band(
      xv,
      yv,
      grid,
      ci,
      n_boot,
      seed,
      order = order,
      logistic = logistic,
      lowess = lowess,
      robust = robust,
      logx = logx
    )
    if (!is.null(band)) {
      p <- p +
        ggplot2::geom_ribbon(
          data = band,
          mapping = ggplot2::aes(
            x = .data$grid,
            ymin = .data$lo,
            ymax = .data$hi
          ),
          inherit.aes = FALSE,
          fill = col,
          alpha = 0.15
        )
    }
    lk <- line_kws %||% list()
    p <- p +
      ggplot2::geom_line(
        data = fit_df,
        mapping = ggplot2::aes(x = .data$grid, y = .data$yhat),
        inherit.aes = FALSE,
        colour = lk$color %||% col,
        linewidth = lk$linewidth %||% rb_line_default_width()
      )
  }

  p <- p +
    ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
    ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
  p <- rb_finish_plot(p, xlab = v$names$x, ylab = v$names$y, legend = FALSE)
  reaborn_plot(p, call = match.call())
}

#' Plot the residuals of a linear regression
#'
#' Port of `seaborn.residplot`. Returns a [reaborn_plot].
#'
#' @inheritParams regplot
#' @param lowess Add a lowess smooth of the residuals.
#' @return A `reaborn_plot`.
#' @param robust Fit a robust regression when computing residuals.
#' @examples
#' tips <- load_dataset("tips")
#' residplot(data = tips, x = "total_bill", y = "tip")
#'
#' # Add a lowess smooth to help detect structure in the residuals
#' residplot(data = tips, x = "total_bill", y = "tip", lowess = TRUE)
#' @export
residplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  lowess = FALSE,
  order = 1,
  robust = FALSE,
  color = NULL,
  scatter_kws = NULL,
  line_kws = NULL,
  ...
) {
  v <- rb_assign_variables(data, x = x, y = y)
  df <- rb_drop_na(v$data, c("x", "y"))
  fit <- stats::lm(df$y ~ stats::poly(df$x, order, raw = TRUE))
  resid <- stats::residuals(fit)
  rdf <- data.frame(x = df$x, resid = resid)
  col <- color %||% color_palette(.reaborn_get("palette", "deep"), 1)

  p <- ggplot2::ggplot(rdf, ggplot2::aes(x = .data$x, y = .data$resid)) +
    ggplot2::geom_hline(
      yintercept = 0,
      linewidth = rb_line_default_width(),
      colour = RB_BOX_LINECOLOR
    ) +
    ggplot2::geom_point(
      colour = col,
      fill = col,
      shape = 21,
      stroke = 0,
      size = rb_area_to_size(36)
    )
  if (lowess) {
    lo <- stats::lowess(rdf$x, rdf$resid, f = 2 / 3)
    p <- p +
      ggplot2::geom_line(
        data = data.frame(x = lo$x, y = lo$y),
        mapping = ggplot2::aes(x = .data$x, y = .data$y),
        inherit.aes = FALSE,
        colour = col,
        linewidth = rb_line_default_width()
      )
  }
  p <- p +
    ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
    ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
  p <- rb_finish_plot(p, xlab = v$names$x, ylab = "Residuals", legend = FALSE)
  reaborn_plot(p, call = match.call())
}

#' Figure-level interface for regression plots
#'
#' Port of `seaborn.lmplot`. Draws [regplot] across a grid of facets and/or hue
#' groups. Returns a [reaborn_plot].
#'
#' @inheritParams regplot
#' @param hue,col,row Semantic / faceting variables.
#' @param col_wrap,row_order,col_order,hue_order Ordering / wrapping.
#' @param palette Hue palette.
#' @param height,aspect Facet sizing.
#' @param legend,facet_kws Legend / facet options.
#' @return A `reaborn_plot`.
#' @examples
#' tips <- load_dataset("tips")
#' lmplot(data = tips, x = "total_bill", y = "tip", hue = "smoker")
#'
#' # Facet across a second variable with col
#' lmplot(data = tips, x = "total_bill", y = "tip", hue = "smoker", col = "time")
#' @export
lmplot <- function(
  data = NULL,
  x = NULL,
  y = NULL,
  hue = NULL,
  col = NULL,
  row = NULL,
  palette = NULL,
  col_wrap = NULL,
  height = 5,
  aspect = 1,
  order = 1,
  logistic = FALSE,
  lowess = FALSE,
  robust = FALSE,
  logx = FALSE,
  ci = 95,
  n_boot = 1000,
  seed = NULL,
  scatter = TRUE,
  fit_reg = TRUE,
  hue_order = NULL,
  row_order = NULL,
  col_order = NULL,
  legend = TRUE,
  facet_kws = NULL,
  ...
) {
  v <- rb_assign_variables(data, x = x, y = y, hue = hue)
  df <- rb_drop_na(v$data, c("x", "y"))
  base <- if (is.data.frame(data)) {
    data[stats::complete.cases(v$data[c("x", "y")]), , drop = FALSE]
  } else {
    df
  }

  p <- ggplot2::ggplot(base, ggplot2::aes(x = .data[[x]], y = .data[[y]]))

  hue_present <- !is.null(hue)
  if (hue_present) {
    lv <- rb_categorical_order(base[[hue]], hue_order)
    base[[hue]] <- factor(as.character(base[[hue]]), levels = lv)
    colors <- stats::setNames(rb_categorical_colors(length(lv), palette), lv)
    groups <- lv
  } else {
    colors <- stats::setNames(
      color_palette(.reaborn_get("palette", "deep"), 1),
      "_all"
    )
    groups <- "_all"
  }

  # Draw scatter + fit per hue group (so colors and fits separate).
  for (g in groups) {
    sub <- if (hue_present) {
      base[as.character(base[[hue]]) == g, , drop = FALSE]
    } else {
      base
    }
    gcol <- colors[[g]]
    if (scatter) {
      p <- p +
        ggplot2::geom_point(
          data = sub,
          colour = gcol,
          fill = gcol,
          shape = 21,
          stroke = 0,
          size = rb_area_to_size(36)
        )
    }
    if (fit_reg && nrow(sub) > order + 1) {
      grid <- seq(min(sub[[x]]), max(sub[[x]]), length.out = 100)
      yhat <- .rb_reg_fit(
        sub[[x]],
        sub[[y]],
        grid,
        order = order,
        logistic = logistic,
        lowess = lowess,
        robust = robust,
        logx = logx
      )
      band <- .rb_reg_band(
        sub[[x]],
        sub[[y]],
        grid,
        ci,
        n_boot,
        seed,
        order = order,
        logistic = logistic,
        lowess = lowess,
        robust = robust,
        logx = logx
      )
      if (!is.null(band)) {
        p <- p +
          ggplot2::geom_ribbon(
            data = band,
            inherit.aes = FALSE,
            mapping = ggplot2::aes(
              x = .data$grid,
              ymin = .data$lo,
              ymax = .data$hi
            ),
            fill = gcol,
            alpha = 0.15
          )
      }
      p <- p +
        ggplot2::geom_line(
          data = data.frame(grid = grid, yhat = yhat),
          mapping = ggplot2::aes(x = .data$grid, y = .data$yhat),
          inherit.aes = FALSE,
          colour = gcol,
          linewidth = rb_line_default_width()
        )
    }
  }

  # Legend proxy for hue (regression layers don't generate one).
  if (hue_present) {
    p <- p +
      ggplot2::geom_point(
        data = base,
        mapping = ggplot2::aes(
          x = .data[[x]],
          y = .data[[y]],
          colour = .data[[hue]]
        ),
        alpha = 0,
        show.legend = TRUE
      ) +
      ggplot2::scale_colour_manual(values = colors, name = hue) +
      ggplot2::guides(
        colour = ggplot2::guide_legend(override.aes = list(alpha = 1, size = 2))
      )
  }

  p <- rb_facet(p, base, row, col, col_wrap, row_order, col_order)
  p <- p +
    ggplot2::scale_x_continuous(breaks = rb_mpl_breaks()) +
    ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
  p <- rb_finish_plot(
    p,
    xlab = v$names$x,
    ylab = v$names$y,
    legend = if (isFALSE(legend)) FALSE else "auto"
  )
  if (hue_present || !is.null(col) || !is.null(row)) {
    p <- p + rb_legend_right()
  }
  attr(p, "rb_height") <- height
  attr(p, "rb_aspect") <- aspect
  reaborn_plot(p, call = match.call())
}
