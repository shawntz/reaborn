# The reaborn_plot class. A reaborn plot IS a ggplot (it carries the ggplot
# classes), so it composes with the entire ggplot2 grammar: `p + geom_*()`,
# `p + facet_wrap()`, `p + scale_*()`, `p + theme()`. The thin subclass exists
# only to (a) keep a friendly print banner and (b) record the originating
# seaborn-style call for debugging. The seaborn *look* comes from the global
# theme installed by set_theme() (called on package load), exactly mirroring
# how seaborn mutates matplotlib's global rcParams.

#' Wrap a ggplot as a reaborn plot
#'
#' @param plot A ggplot object.
#' @param call Optional originating call, recorded as an attribute.
#' @return The plot with class `reaborn_plot` prepended.
#' @keywords internal
reaborn_plot <- function(plot, call = NULL) {
  if (!inherits(plot, "ggplot")) {
    stop("reaborn_plot() expects a ggplot object")
  }
  if (!inherits(plot, "reaborn_plot")) {
    class(plot) <- c("reaborn_plot", class(plot))
  }
  attr(plot, "reaborn_call") <- call
  plot
}

# The column name(s) a single facet quosure references. Plain symbols
# (`~species`, `vars(species)`) come from all.vars(); the tidy-eval pronoun form
# `.data[["col"]]` / `.data[[var]]` -- for which all.vars() yields the useless
# ".data" -- is unwrapped by reading its index (evaluating a variable index in
# the quosure's environment). Also handles the `.data$col` variant.
rb_facet_quo_var <- function(q) {
  is_quo <- rlang::is_quosure(q)
  expr <- if (is_quo) rlang::quo_get_expr(q) else q
  if (
    is.call(expr) &&
      length(expr) == 3L &&
      identical(expr[[2]], as.name(".data")) &&
      (identical(expr[[1]], as.name("[[")) ||
        identical(expr[[1]], as.name("$")))
  ) {
    idx <- expr[[3]]
    # `.data$col` takes the field name literally; `.data[[x]]` may index by a
    # string literal or by a variable resolved in the quosure's environment.
    if (identical(expr[[1]], as.name("$")) || is.character(idx)) {
      return(as.character(idx))
    }
    env <- if (is_quo) rlang::quo_get_env(q) else baseenv()
    return(tryCatch(as.character(eval(idx, env)), error = function(e) {
      character(0)
    }))
  }
  all.vars(expr)
}

# The data-column names a ggplot2 Facet references (facet_wrap or facet_grid),
# used to re-aggregate a categorical plot per panel before the facet is applied.
#' @keywords internal
rb_facet_vars <- function(facet) {
  quos <- c(
    facet$params$facets, # facet_wrap()
    facet$params$rows, # facet_grid(rows =)
    facet$params$cols # facet_grid(cols =)
  )
  if (!length(quos)) {
    return(character(0))
  }
  unique(unlist(lapply(quos, rb_facet_quo_var)))
}

#' Add to a reaborn plot, preserving its class
#'
#' Ensures `reaborn_plot + <ggplot component>` stays a `reaborn_plot` so the
#' composed object keeps printing through reaborn and remains chainable.
#'
#' Categorical plots collapse their data (via `rb_cat_setup()`, and for
#' bar/point/count an estimator aggregation), so the facet variable is absent
#' from the plotted data. When such a plot carries a re-aggregation hook and the
#' user adds a facet, we rebuild it with the facet columns forwarded through
#' setup + aggregation (the same `.facet_vars` path `catplot()` uses) and then
#' apply the user's facet -- so each panel shows, and for aggregating kinds
#' re-estimates, its own subset instead of one shared full-data summary (#73).
#' @param e1 A reaborn plot.
#' @param e2 A ggplot component (geom, scale, theme, facet, ...).
#' @return A reaborn plot.
#' @keywords internal
#' @export
"+.reaborn_plot" <- function(e1, e2) {
  refacet <- attr(e1, "rb_refacet")
  if (!is.null(refacet) && inherits(e2, "Facet")) {
    fvars <- rb_facet_vars(e2)
    if (length(fvars)) {
      rebuilt <- refacet(fvars)
      # The rebuild carries a fresh hook; drop it so replaying components and
      # applying the user's facet compose as ordinary ggplot additions. Keep the
      # original seaborn-style call rather than the do.call() the hook used.
      attr(rebuilt, "rb_refacet") <- NULL
      attr(rebuilt, "reaborn_call") <- attr(e1, "reaborn_call")
      for (comp in attr(e1, "rb_pending") %||% list()) {
        rebuilt <- rebuilt + comp
      }
      return(rebuilt + e2)
    }
  }
  res <- NextMethod()
  if (inherits(res, "ggplot") && !inherits(res, "reaborn_plot")) {
    class(res) <- c("reaborn_plot", class(res))
    attr(res, "reaborn_call") <- attr(e1, "reaborn_call")
  }
  # Carry the hook (and any components added before faceting) forward so
  # `barplot(...) + scale_*() + facet_wrap(...)` still re-aggregates per panel.
  if (!is.null(refacet)) {
    attr(res, "rb_refacet") <- refacet
    attr(res, "rb_pending") <- c(attr(e1, "rb_pending") %||% list(), list(e2))
  }
  res
}

#' @export
print.reaborn_plot <- function(x, ...) {
  # Render through ggplot2's printer; the active global theme (set by
  # set_theme()) supplies the seaborn look, while any theme elements the user
  # added to the plot take precedence over it.
  NextMethod()
  invisible(x)
}
