# Shared finishing logic applied to every reaborn plot: matplotlib-style axis
# breaks on continuous axes, axis labels from the original variable names, and
# seaborn-like legend placement (inside the axes at the emptiest corner, the way
# matplotlib's "best" location behaves).

# Build the base plotting frame. Crucially it RETAINS all original data columns
# (when a data frame was supplied) so that downstream ggplot composition --
# `p + facet_wrap(~other_col)`, adding layers referencing other columns -- works.
# Returns the NA-filtered base frame, the role-named frame `vd` (for resolving
# semantics), and the column names to map for x and y.
#' @keywords internal
rb_make_base <- function(data, v, used_roles) {
  used <- intersect(used_roles, names(v$data))
  keep <- if (nrow(v$data)) stats::complete.cases(v$data[used]) else logical(0)
  vd <- v$data[keep, , drop = FALSE]
  if (is.data.frame(data)) {
    base <- data[keep, , drop = FALSE]
    rownames(base) <- NULL
  } else {
    base <- vd[, intersect(c("x", "y"), names(vd)), drop = FALSE]
  }
  list(base = base, vd = vd, keep = keep)
}

# Decide which column name to map for a role: the original data column if it was
# referenced by string, otherwise inject an internal column into `base`.
#' @keywords internal
rb_role_col <- function(base, vd, ref, role, internal) {
  if (is.character(ref) && length(ref) == 1L && ref %in% names(base)) {
    return(list(base = base, col = ref))
  }
  base[[internal]] <- vd[[role]]
  list(base = base, col = internal)
}

#' @keywords internal
rb_finish_plot <- function(p, xlab = NULL, ylab = NULL, legend = "auto",
                           legend_data = NULL, any_legend = FALSE, breaks = TRUE) {
  # Continuous axes get matplotlib-style tick locations (unless the caller has
  # already added its own scales, e.g. histplot/kdeplot).
  if (breaks && !is.null(legend_data)) {
    if (is.numeric(legend_data$x)) {
      p <- p + ggplot2::scale_x_continuous(breaks = rb_mpl_breaks())
    }
    if (is.numeric(legend_data$y)) {
      p <- p + ggplot2::scale_y_continuous(breaks = rb_mpl_breaks())
    }
  }

  if (!is.null(xlab)) p <- p + ggplot2::labs(x = xlab)
  if (!is.null(ylab)) p <- p + ggplot2::labs(y = ylab)

  if (isFALSE(legend) || identical(legend, "none")) {
    p <- p + ggplot2::theme(legend.position = "none")
  } else if (any_legend && !is.null(legend_data) &&
             is.numeric(legend_data$x) && is.numeric(legend_data$y)) {
    corner <- rb_best_legend_corner(legend_data$x, legend_data$y)
    # seaborn keeps matplotlib's default legend frame: the background inherits the
    # axes facecolor (so it reads against the gridded panel), bordered by a faint
    # gray (0.8) edge, with a centered title and the keys themselves transparent.
    facecol <- .rb_col(axes_style()$facecolor)
    p <- p + ggplot2::theme(
      legend.position = "inside",
      legend.position.inside = corner$inside,
      legend.justification.inside = corner$inside,
      legend.background = ggplot2::element_rect(fill = facecol, colour = .rb_col(".8"),
                                                linewidth = .rb_lw(0.8)),
      legend.key = ggplot2::element_rect(fill = NA, colour = NA),
      # matplotlib handles are wide and short (handlelength 2, handleheight 0.7),
      # with a little breathing room between rows.
      legend.key.width = grid::unit(1.7, "lines"),
      legend.key.height = grid::unit(0.85, "lines"),
      legend.key.spacing.y = grid::unit(2.5, "pt"),
      legend.title = ggplot2::element_text(hjust = 0.5),
      legend.margin = ggplot2::margin(3, 5, 3, 5)
    )
  }
  p
}

# Theme partial that places a legend outside, to the right of the axes (used by
# the figure-level dispatchers and for hue legends on categorical axes). It also
# undoes the inside-axes frame styling rb_finish_plot may have applied -- the
# bordered box and centered title belong only to a legend that sits *inside* the
# panel, whereas seaborn's outside legends are unframed with a left-aligned title.
#' @keywords internal
rb_legend_right <- function() {
  ggplot2::theme(
    legend.position = "right",
    legend.background = ggplot2::element_blank(),
    legend.title = ggplot2::element_text(hjust = 0)
  )
}
