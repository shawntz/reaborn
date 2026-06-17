# Matrix plots: heatmap (clustermap deferred to M4). Port of seaborn/matrix.py.

# Relative luminance of a color (seaborn.utils.relative_luminance): used to pick
# black vs white annotation text so it stays readable on each cell.
rb_relative_luminance <- function(color) {
  rgb <- rb_color_to_rgb(color)
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  sum(c(0.2126, 0.7152, 0.0722) * lin)
}

#' Plot rectangular data as a color-encoded matrix
#'
#' Port of `seaborn.heatmap`. Returns a [reaborn_plot].
#'
#' @param data A matrix or data frame of values.
#' @param vmin,vmax Color scale limits.
#' @param cmap A colormap name (default `"rocket"`, or `"icefire"` with `center`).
#' @param center Value at which to center a diverging colormap.
#' @param robust Use the 2nd/98th percentiles for the color limits.
#' @param annot Annotate each cell with its value (`TRUE`) or a matrix of labels.
#' @param fmt Number format for annotations (default `".2g"`).
#' @param annot_kws Passed to the text geom.
#' @param linewidths,linecolor Cell border width and color.
#' @param cbar Show the color bar.
#' @param square Force square cells.
#' @param xticklabels,yticklabels Tick label control (`"auto"`, `TRUE`/`FALSE`).
#' @param mask Logical matrix of cells to hide.
#' @param ... Reserved.
#' @return A `reaborn_plot`.
#' @export
heatmap <- function(data, vmin = NULL, vmax = NULL, cmap = NULL, center = NULL,
                    robust = FALSE, annot = NULL, fmt = ".2g", annot_kws = NULL,
                    linewidths = 0, linecolor = "white", cbar = TRUE,
                    square = FALSE, xticklabels = "auto", yticklabels = "auto",
                    mask = NULL, ...) {
  mat <- as.matrix(data)
  rows <- rownames(mat) %||% as.character(seq_len(nrow(mat)))
  cols <- colnames(mat) %||% as.character(seq_len(ncol(mat)))
  storage.mode(mat) <- "double"
  if (!is.null(mask)) mat[as.matrix(mask)] <- NA

  long <- expand.grid(row = rows, col = cols, stringsAsFactors = FALSE)
  long$value <- as.vector(mat)
  long$row <- factor(long$row, levels = rev(rows))   # first row at top
  long$col <- factor(long$col, levels = cols)

  vals <- mat[is.finite(mat)]
  if (robust) {
    lims <- stats::quantile(vals, c(0.02, 0.98), names = FALSE, type = 7)
    vmin <- vmin %||% lims[1]; vmax <- vmax %||% lims[2]
  } else {
    vmin <- vmin %||% min(vals); vmax <- vmax %||% max(vals)
  }

  # Resolve the colormap.
  if (is.null(cmap)) cmap <- if (is.null(center)) "rocket" else "icefire"
  cmap_obj <- if (length(cmap) > 1) rb_make_cmap(t(vapply(cmap, rb_color_to_rgb, numeric(3)))) else color_palette(cmap, as_cmap = TRUE)
  cmap_cols <- attr(cmap_obj, "colors")

  # Recenter a diverging colormap around `center`.
  if (!is.null(center)) {
    vrange <- max(vmax - center, center - vmin)
    vmin <- center - vrange; vmax <- center + vrange
  }

  fill_scale <- ggplot2::scale_fill_gradientn(
    colours = cmap_cols, limits = c(vmin, vmax),
    oob = scales::squish, guide = if (cbar) "colourbar" else "none", name = NULL)

  tile_lw <- if (linewidths > 0) .rb_lw(linewidths) else 0
  p <- ggplot2::ggplot(long, ggplot2::aes(x = .data$col, y = .data$row, fill = .data$value)) +
    ggplot2::geom_tile(colour = if (linewidths > 0) linecolor else NA, linewidth = tile_lw) +
    fill_scale

  # Annotations with luminance-based text color (threshold 0.408).
  if (!is.null(annot) && !isFALSE(annot)) {
    labels <- if (is.logical(annot)) {
      rb_format_value(long$value, fmt)
    } else {
      as.vector(as.matrix(annot))
    }
    # Cell fill color -> luminance -> text color.
    rescaled <- pmin(pmax((long$value - vmin) / (vmax - vmin), 0), 1)
    cell_cols <- cmap_obj(rescaled)
    lum <- vapply(cell_cols, rb_relative_luminance, numeric(1))
    text_col <- ifelse(lum > 0.408, "#262626", "#FFFFFF")
    ak <- annot_kws %||% list()
    adf <- long; adf$label <- labels; adf$tcol <- text_col
    adf <- adf[!is.na(adf$value), ]
    p <- p + ggplot2::geom_text(data = adf,
      mapping = ggplot2::aes(label = .data$label), colour = adf$tcol,
      size = (ak$size %||% 11) / .rb_PT_FONT)
  }

  dn <- names(dimnames(mat))
  xlab <- if (length(dn) == 2 && nzchar(dn[2])) dn[2] else NULL
  ylab <- if (length(dn) == 2 && nzchar(dn[1])) dn[1] else NULL
  p <- p + ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::labs(x = xlab, y = ylab)
  if (square) p <- p + ggplot2::coord_fixed()

  # Heatmap chrome: no grid/border, ticks present, like seaborn.
  p <- p + ggplot2::theme(
    panel.grid = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_line(colour = .rb_col(DARK_GRAY), linewidth = .rb_lw(1.25)),
    panel.background = ggplot2::element_blank()
  )
  reaborn_plot(p, call = match.call())
}

# Font point-size -> ggplot geom_text size conversion.
.rb_PT_FONT <- 2.845276

# Translate a Python format spec (e.g. ".2g", "d", ".1f", ".0%") to formatted
# strings, matching seaborn's annot fmt.
rb_format_value <- function(x, fmt) {
  fmt <- sub("^:", "", fmt)
  m <- regmatches(fmt, regexec("^\\.?([0-9]+)?([gGfeEd%])$", fmt))[[1]]
  if (length(m) == 3) {
    digits <- if (nzchar(m[2])) as.integer(m[2]) else 6L
    type <- m[3]
    if (type == "d") return(formatC(round(x), format = "d"))
    if (type == "%") return(paste0(formatC(x * 100, format = "f", digits = digits), "%"))
    return(formatC(x, format = tolower(type), digits = digits))
  }
  if (fmt == "d") return(formatC(round(x), format = "d"))
  format(x)
}
