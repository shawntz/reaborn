# Shared internal utilities used across reaborn.

#' Matplotlib-style axis breaks
#'
#' Approximates matplotlib's `MaxNLocator` / `AutoLocator` (the default axis tick
#' locator), which places ticks at "nice" round numbers using the step sequence
#' 1, 2, 2.5, 5, 10. ggplot2's default (`scales::extended_breaks`) targets fewer
#' ticks and lands on different values, so reaborn plots use this to match
#' seaborn's gridline density and tick positions.
#'
#' @param n Target maximum number of intervals (matplotlib's default is ~9).
#' @return A function of `limits` returning a numeric vector of break positions,
#'   suitable for the `breaks` argument of a ggplot2 continuous scale.
#' @keywords internal
#' @export
rb_mpl_breaks <- function(n = 9) {
  function(limits) {
    limits <- limits[is.finite(limits)]
    if (length(limits) < 2) return(numeric(0))
    lo <- min(limits); hi <- max(limits)
    rng <- hi - lo
    if (rng <= 0) return(lo)
    steps <- c(1, 2, 2.5, 5, 10)
    raw <- rng / n
    mag <- 10^floor(log10(raw))
    norm <- raw / mag
    step <- mag * steps[which(steps >= norm)[1]]
    if (length(step) == 0 || is.na(step)) step <- mag * 10
    start <- ceiling(lo / step - 1e-9) * step
    end <- floor(hi / step + 1e-9) * step
    seq(start, end, by = step)
  }
}

# Choose the emptiest corner for an inside legend, approximating matplotlib's
# "best" legend placement (which minimizes the overlap area between the legend
# box and the plotted artists). Returns a list(inside, name) for ggplot2 theme().
rb_best_legend_corner <- function(x, y) {
  corners <- list(
    "upper right" = c(0.98, 0.98), "upper left"  = c(0.02, 0.98),
    "lower left"  = c(0.02, 0.02), "lower right" = c(0.98, 0.02)
  )
  ok <- is.finite(x) & is.finite(y)
  x <- x[ok]; y <- y[ok]
  if (length(x) < 2 || diff(range(x)) == 0 || diff(range(y)) == 0) {
    return(list(inside = corners[["upper right"]], name = "upper right"))
  }
  nx <- (x - min(x)) / diff(range(x))
  ny <- (y - min(y)) / diff(range(y))
  # Rasterize the data onto a coarse grid and score each corner by how many
  # occupied cells fall under a legend-sized footprint there. Counting occupied
  # CELLS rather than raw samples keeps a tall, narrow peak (few samples, big
  # visual footprint) from being under-weighted the way a point count would --
  # that is what makes this track matplotlib's "best" on density/line plots.
  ng <- 12L; fx <- 0.45; fy <- 0.45
  gx <- pmin(ng, floor(nx * ng) + 1L)
  gy <- pmin(ng, floor(ny * ng) + 1L)
  occ <- matrix(FALSE, ng, ng)
  occ[cbind(gx, gy)] <- TRUE
  kx <- ceiling(fx * ng); ky <- ceiling(fy * ng)
  lo_x <- seq_len(kx);          hi_x <- (ng - kx + 1L):ng
  lo_y <- seq_len(ky);          hi_y <- (ng - ky + 1L):ng
  # Order matches matplotlib's candidate iteration so ties resolve to "best".
  cost <- c(
    "upper right" = sum(occ[hi_x, hi_y]),
    "upper left"  = sum(occ[lo_x, hi_y]),
    "lower left"  = sum(occ[lo_x, lo_y]),
    "lower right" = sum(occ[hi_x, lo_y])
  )
  best <- names(which.min(cost))
  list(inside = corners[[best]], name = best)
}

# Null-coalescing operator (also defined in rcmod-theme.R for load ordering; kept
# here too so utils is self-contained).
if (!exists("%||%")) {
  `%||%` <- function(a, b) if (is.null(a)) b else a
}
