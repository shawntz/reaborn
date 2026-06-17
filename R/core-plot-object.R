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

#' Add to a reaborn plot, preserving its class
#'
#' Ensures `reaborn_plot + <ggplot component>` stays a `reaborn_plot` so the
#' composed object keeps printing through reaborn and remains chainable.
#' @param e1 A reaborn plot.
#' @param e2 A ggplot component (geom, scale, theme, facet, ...).
#' @return A reaborn plot.
#' @keywords internal
#' @export
"+.reaborn_plot" <- function(e1, e2) {
  res <- NextMethod()
  if (inherits(res, "ggplot") && !inherits(res, "reaborn_plot")) {
    class(res) <- c("reaborn_plot", class(res))
    attr(res, "reaborn_call") <- attr(e1, "reaborn_call")
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
