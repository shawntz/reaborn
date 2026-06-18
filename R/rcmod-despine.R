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
  spec <- .rb_legend_loc(loc)
  if (is.list(spec)) {
    # Inside the panel: anchor the legend's matching corner (justification) to a
    # point near that corner of the panel (position), the way matplotlib/seaborn
    # place "lower left" etc. ggplot2's default justification is the legend
    # CENTRE, which would push the box half off the panel edge.
    ggplot2::theme(
      legend.position = "inside",
      legend.position.inside = spec$position,
      legend.justification.inside = spec$justification
    )
  } else {
    ggplot2::theme(legend.position = spec)
  }
}

# Translate a matplotlib legend location into ggplot2 terms. Returns a character
# keyword for outside placements, or a list(position, justification) for the
# inside placements that ggplot2 anchors by corner.
.rb_legend_loc <- function(loc) {
  # matplotlib: a numeric 2-tuple anchors the legend's lower-left corner there.
  # Coordinates may sit outside [0, 1] to place the legend beyond the panel, as
  # in matplotlib, but they must be a finite pair.
  if (is.numeric(loc)) {
    if (length(loc) != 2L || !all(is.finite(loc))) {
      stop(
        "`loc` must be a length-2 numeric vector of relative coordinates ",
        "(e.g. c(0.5, 0.5)) or a matplotlib location string."
      )
    }
    return(list(position = loc, justification = c(0, 0)))
  }
  inside <- list(
    "upper right" = list(position = c(0.98, 0.98), justification = c(1, 1)),
    "lower right" = list(position = c(0.98, 0.02), justification = c(1, 0)),
    "upper left" = list(position = c(0.02, 0.98), justification = c(0, 1)),
    "lower left" = list(position = c(0.02, 0.02), justification = c(0, 0)),
    "center" = list(position = c(0.5, 0.5), justification = c(0.5, 0.5))
  )
  if (loc %in% names(inside)) {
    return(inside[[loc]])
  }
  switch(
    loc,
    "best" = "right",
    "right" = "right",
    "center right" = "right",
    "left" = "left",
    "center left" = "left",
    "upper center" = "top",
    "lower center" = "bottom",
    "right"
  )
  if (loc %in% names(inside)) return(inside[[loc]])
  switch(loc,
    "best" = "right", "right" = "right", "center right" = "right",
    "left" = "left", "center left" = "left",
    "upper center" = "top", "lower center" = "bottom",
    "right")
}
