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

# Null-coalescing operator (also defined in rcmod-theme.R for load ordering; kept
# here too so utils is self-contained).
if (!exists("%||%")) {
  `%||%` <- function(a, b) if (is.null(a)) b else a
}
