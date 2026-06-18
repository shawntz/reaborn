# Estimation + error intervals. Port of seaborn._statistics.EstimateAggregator
# and seaborn.algorithms.bootstrap. Used by lineplot (and later barplot /
# pointplot / regression) to compute a point estimate and an error interval per
# group. NOTE: seaborn bootstraps with numpy's PCG64 RNG; R uses Mersenne-Twister,
# so seeded bootstrap CIs are statistically equivalent but not sample-identical.

# Apply a named or callable estimator to a numeric vector.
rb_apply_estimator <- function(vals, estimator = "mean") {
  if (is.function(estimator)) return(estimator(vals))
  switch(estimator,
    mean = mean(vals, na.rm = TRUE),
    median = stats::median(vals, na.rm = TRUE),
    sum = sum(vals, na.rm = TRUE),
    sd = stats::sd(vals, na.rm = TRUE),
    std = stats::sd(vals, na.rm = TRUE),
    min = min(vals, na.rm = TRUE),
    max = max(vals, na.rm = TRUE),
    count = length(vals),
    stop(sprintf("Unknown estimator '%s'", estimator))
  )
}

# Normalize the `errorbar` argument to list(method, level). Mirrors seaborn's
# _validate_errorbar_arg: "ci"/"pi" default to level 95, "se"/"sd" to 1.
rb_parse_errorbar <- function(errorbar = list("ci", 95)) {
  if (is.null(errorbar)) return(list(method = NULL, level = NULL))
  if (is.function(errorbar)) return(list(method = errorbar, level = NULL))
  if (is.character(errorbar) && length(errorbar) == 1L) {
    method <- errorbar
    level <- if (method %in% c("ci", "pi")) 95 else 1
    return(list(method = method, level = level))
  }
  # tuple/list like list("ci", 95) or c("ci", "95")
  method <- errorbar[[1]]
  level <- as.numeric(errorbar[[2]])
  list(method = method, level = level)
}

# Percentile interval of a given width (e.g. 95 -> [2.5, 97.5] percentiles).
rb_percentile_interval <- function(data, width) {
  edge <- (100 - width) / 2
  stats::quantile(data, c(edge, 100 - edge) / 100, na.rm = TRUE, names = FALSE)
}

# Bootstrap an estimator over a vector. Returns the bootstrap distribution.
rb_bootstrap <- function(vals, estimator = "mean", n_boot = 1000, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  n <- length(vals)
  if (n == 0) return(rep(NA_real_, n_boot))
  vapply(seq_len(n_boot), function(i) {
    rb_apply_estimator(vals[sample.int(n, n, replace = TRUE)], estimator)
  }, numeric(1))
}

# Aggregate a numeric vector into (estimate, min, max). Mirrors
# EstimateAggregator.__call__.
rb_estimate_aggregator <- function(vals, estimator = "mean",
                                   errorbar = list("ci", 95),
                                   n_boot = 1000, seed = NULL) {
  vals <- vals[!is.na(vals)]
  est <- rb_apply_estimator(vals, estimator)
  eb <- rb_parse_errorbar(errorbar)
  if (is.null(eb$method) || length(vals) <= 1L) {
    return(c(estimate = est, ymin = NA_real_, ymax = NA_real_))
  }
  if (is.function(eb$method)) {
    iv <- eb$method(vals)
    return(c(estimate = est, ymin = iv[1], ymax = iv[2]))
  }
  iv <- switch(eb$method,
    sd = { h <- stats::sd(vals) * eb$level; c(est - h, est + h) },
    se = { h <- stats::sd(vals) / sqrt(length(vals)) * eb$level; c(est - h, est + h) },
    pi = rb_percentile_interval(vals, eb$level),
    ci = {
      boots <- rb_bootstrap(vals, estimator, n_boot, seed)
      rb_percentile_interval(boots, eb$level)
    },
    stop(sprintf("Unknown errorbar method '%s'", eb$method))
  )
  c(estimate = est, ymin = iv[1], ymax = iv[2])
}

# Aggregate a data frame: for each unique combination of `group_cols`, compute
# the estimate + error interval over `value_col` (the dependent axis), plus the
# grouping/position columns. Returns a tidy frame with columns
# <pos_col>, estimate, ymin, ymax, and the group columns.
rb_aggregate <- function(df, pos_col, value_col, group_cols = character(0),
                         estimator = "mean", errorbar = list("ci", 95),
                         n_boot = 1000, seed = NULL) {
  keys <- c(group_cols, pos_col)
  key_str <- interaction(df[keys], drop = TRUE, lex.order = TRUE)
  parts <- split(seq_len(nrow(df)), key_str)
  rows <- lapply(parts, function(idx) {
    sub <- df[idx, , drop = FALSE]
    agg <- rb_estimate_aggregator(sub[[value_col]], estimator, errorbar, n_boot, seed)
    out <- sub[1, keys, drop = FALSE]
    out$estimate <- agg[["estimate"]]
    out$ymin <- agg[["ymin"]]
    out$ymax <- agg[["ymax"]]
    out
  })
  res <- do.call(rbind, rows)
  rownames(res) <- NULL
  res
}
