# Density + histogram-bin estimation, ported to exactly match scipy.gaussian_kde
# and numpy.histogram_bin_edges (NOT R's density()/hist(), whose bandwidth and
# bin rules differ). This is the single most important fidelity component for the
# distribution plots; it is reused by histplot, kdeplot, violinplot, jointplot.

# scipy gaussian_kde bandwidth factor. d = number of dimensions.
.rb_kde_factor <- function(n, d = 1, method = "scott") {
  if (is.numeric(method)) {
    return(method)
  }
  if (identical(method, "silverman")) {
    return((n * (d + 2) / 4)^(-1 / (d + 4)))
  }
  # scott (scipy default)
  n^(-1 / (d + 4))
}

#' Univariate Gaussian KDE matching scipy.stats.gaussian_kde
#'
#' @param x Numeric data.
#' @param bw_method `"scott"` (default), `"silverman"`, or a numeric factor.
#' @param bw_adjust Multiplicative bandwidth adjustment (seaborn `bw_adjust`).
#' @param gridsize Number of evaluation points (seaborn default 200).
#' @param cut Extend the grid `cut` bandwidths past the data extremes (default 3).
#' @param clip Length-2 numeric clip for the grid, or `NULL`.
#' @param weights Optional observation weights.
#' @param cumulative Return the cumulative distribution instead of the density.
#' @return A list with `x` (grid) and `y` (density) vectors.
#' @keywords internal
rb_gaussian_kde <- function(
  x,
  bw_method = "scott",
  bw_adjust = 1,
  gridsize = 200,
  cut = 3,
  clip = NULL,
  weights = NULL,
  cumulative = FALSE
) {
  x <- x[!is.na(x)]
  n <- length(x)
  # scipy.gaussian_kde requires >= 2 points (needs a finite variance); callers
  # skip empty/singleton groups, but bail out gracefully as a backstop so an
  # empty subset never reaches seq() with non-finite bounds.
  if (n < 2) {
    return(list(x = numeric(0), y = numeric(0), bw = NA_real_))
  }
  w <- if (is.null(weights)) rep(1 / n, n) else weights / sum(weights)
  # scipy uses the (weighted) sample covariance with bias correction.
  if (is.null(weights)) {
    data_var <- stats::var(x) # ddof = 1
  } else {
    mu <- sum(w * x)
    neff <- 1 / sum(w^2)
    data_var <- sum(w * (x - mu)^2) * neff / (neff - 1)
  }
  factor <- .rb_kde_factor(n, 1, bw_method) * bw_adjust
  covariance <- factor^2 * data_var
  bw <- sqrt(covariance)

  lo <- min(x) - bw * cut
  hi <- max(x) + bw * cut
  if (!is.null(clip)) {
    if (is.finite(clip[1])) {
      lo <- max(lo, clip[1])
    }
    if (is.finite(clip[2])) hi <- min(hi, clip[2])
  }
  grid <- seq(lo, hi, length.out = gridsize)

  # density(g) = sum_i w_i * N(g; x_i, bw)
  dens <- vapply(grid, function(g) sum(w * stats::dnorm(g, x, bw)), numeric(1))

  if (cumulative) {
    # Cumulative via analytic normal CDF mixture (matches integrate_box_1d).
    dens <- vapply(
      grid,
      function(g) sum(w * stats::pnorm(g, x, bw)),
      numeric(1)
    )
  }
  list(x = grid, y = dens, bw = bw)
}

# ---- numpy.histogram_bin_edges port ----------------------------------------

.rb_iqr <- function(x) {
  qs <- stats::quantile(x, c(0.75, 0.25), names = FALSE, type = 7) # numpy linear
  qs[1] - qs[2]
}

# Bin WIDTH for each reference rule (mirrors numpy._hist_bin_* exactly).
.rb_bin_width <- function(x, rule) {
  n <- length(x)
  ptp <- max(x) - min(x)
  switch(
    rule,
    sturges = ptp / (log2(n) + 1),
    rice = ptp / (2 * n^(1 / 3)),
    sqrt = ptp / sqrt(n),
    scott = (24 * sqrt(pi) / n)^(1 / 3) * stats::sd(x),
    fd = {
      iqr <- .rb_iqr(x)
      2 * iqr / n^(1 / 3)
    },
    doane = {
      if (n <= 2) {
        return(0)
      }
      sg1 <- sqrt(6 * (n - 2) / ((n + 1) * (n + 3)))
      mu <- mean(x)
      sigma <- sqrt(mean((x - mu)^2))
      if (sigma == 0) {
        return(0)
      }
      g1 <- mean(((x - mu) / sigma)^3)
      ptp / (1 + log2(n) + log2(1 + abs(g1) / sg1))
    },
    auto = {
      fd_bw <- .rb_bin_width(x, "fd")
      st_bw <- .rb_bin_width(x, "sturges")
      if (fd_bw > 0) min(fd_bw, st_bw) else st_bw
    },
    stop(sprintf("Unknown bin rule '%s'", rule))
  )
}

#' Histogram bin edges matching numpy.histogram_bin_edges
#'
#' @param x Numeric data.
#' @param bins A rule name (`"auto"`, `"fd"`, `"sturges"`, `"scott"`, `"rice"`,
#'   `"sqrt"`, `"doane"`), an integer bin count, or an explicit numeric vector of
#'   edges.
#' @param binrange Optional `c(min, max)` overriding the data extremes.
#' @param binwidth Optional explicit bin width (overrides `bins`).
#' @param discrete If `TRUE`, place bins on integer centers.
#' @return A numeric vector of bin edges.
#' @keywords internal
rb_hist_bins <- function(
  x,
  bins = "auto",
  binrange = NULL,
  binwidth = NULL,
  discrete = FALSE
) {
  x <- x[!is.na(x)]
  rng <- binrange %||% c(min(x), max(x))
  first <- rng[1]
  last <- rng[2]
  if (discrete) {
    return(seq(first - 0.5, last + 0.5, by = 1))
  }
  if (!is.null(binwidth)) {
    edges <- seq(first, last + binwidth, by = binwidth)
    if (max(edges) < last || length(edges) < 2) {
      edges <- c(edges, max(edges) + binwidth)
    }
    return(edges)
  }
  if (length(bins) > 1) {
    return(bins)
  } # explicit edges
  if (is.numeric(bins)) {
    return(seq(first, last, length.out = as.integer(bins) + 1))
  }
  width <- .rb_bin_width(x[x >= first & x <= last], bins)
  if (!is.finite(width) || width <= 0) {
    n_bins <- 1
  } else {
    n_bins <- as.integer(ceiling((last - first) / width))
  }
  seq(first, last, length.out = n_bins + 1)
}
