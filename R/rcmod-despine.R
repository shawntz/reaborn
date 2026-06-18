# despine() and move_legend(). In seaborn these mutate a matplotlib Axes; in
# reaborn -- where plots are ggplots -- they return objects you ADD to a plot,
# e.g. `p + despine()`. This keeps the composable, grammar-of-graphics model.

#' Remove spines from a plot
#'
#' Port of `seaborn.despine`. Returns a ggplot2 theme partial that removes the
#' requested plot borders and (for borderless styles) draws explicit axis lines
#' on the kept sides. Add it to a reaborn/ggplot plot: `p + despine()`.
#'
#' @param fig,ax Ignored (kept for signature compatibility with seaborn).
#' @param top,right,left,bottom Logical; whether to remove that spine. Defaults
#'   match seaborn: remove top and right, keep left and bottom.
#' @param offset,trim Not supported by ggplot2; accepted but ignored in v1 with
#'   a one-time message. Present for signature compatibility.
#' @return A ggplot2 theme object to add to a plot.
#' @export
despine <- function(fig = NULL, ax = NULL, top = TRUE, right = TRUE,
                    left = FALSE, bottom = FALSE, offset = NULL, trim = FALSE) {
  if (!is.null(offset) || !isFALSE(trim)) {
    rlang::warn(
      "despine(offset=, trim=) is not supported by ggplot2 and is ignored in this version.",
      .frequency = "once", .frequency_id = "reaborn_despine_offset_trim"
    )
  }
  text_col <- .rb_col(DARK_GRAY)
  axis_lw <- .rb_lw(.RB_BASE_CONTEXT$axes.linewidth)
  keep_line <- ggplot2::element_line(colour = text_col, linewidth = axis_lw)

  # Build per-side axis.line elements: a kept side gets a line, a removed side
  # gets blank. Because despine drops the full panel border, re-draw the frame
  # only on the kept sides via axis.line.
  ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    axis.line.x.bottom = if (bottom) ggplot2::element_blank() else keep_line,
    axis.line.x.top    = if (top)    ggplot2::element_blank() else keep_line,
    axis.line.y.left   = if (left)   ggplot2::element_blank() else keep_line,
    axis.line.y.right  = if (right)  ggplot2::element_blank() else keep_line
  )
}

#' Reposition a plot's legend
#'
#' Port of `seaborn.move_legend`. Returns a theme partial controlling legend
#' position. Add it to a plot: `p + move_legend("upper right")`.
#'
#' @param obj Ignored (signature compatibility).
#' @param loc A seaborn/matplotlib location string (e.g. `"upper right"`,
#'   `"center left"`), `"best"`, or a length-2 numeric vector of relative coords.
#' @param ... Additional theme arguments (e.g. `title`).
#' @return A ggplot2 theme object to add to a plot.
#' @export
move_legend <- function(obj = NULL, loc = "best", ...) {
  pos <- .rb_legend_loc(loc)
  if (is.numeric(pos)) {
    ggplot2::theme(legend.position = "inside", legend.position.inside = pos)
  } else {
    ggplot2::theme(legend.position = pos)
  }
}

# Translate a matplotlib legend location into ggplot2 terms.
.rb_legend_loc <- function(loc) {
  if (is.numeric(loc)) return(loc)
  map <- c(
    "best" = "right", "right" = "right", "center right" = "right",
    "left" = "left", "center left" = "left",
    "upper center" = "top", "lower center" = "bottom",
    "upper right" = c(0.98, 0.98), "lower right" = c(0.98, 0.02),
    "upper left" = c(0.02, 0.98), "lower left" = c(0.02, 0.02),
    "center" = c(0.5, 0.5)
  )
  inside <- list(
    "upper right" = c(0.98, 0.98), "lower right" = c(0.98, 0.02),
    "upper left" = c(0.02, 0.98), "lower left" = c(0.02, 0.02),
    "center" = c(0.5, 0.5)
  )
  if (loc %in% names(inside)) return(inside[[loc]])
  switch(loc,
    "best" = "right", "right" = "right", "center right" = "right",
    "left" = "left", "center left" = "left",
    "upper center" = "top", "lower center" = "bottom",
    "right")
}
