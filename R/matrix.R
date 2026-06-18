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
  ctx <- plotting_context()

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

  # Heatmap chrome: seaborn despines the axes and shows no x/y tick marks, and
  # styles the colorbar to match matplotlib's default vertical colorbar -- a
  # full-height, thin, frameless bar with a single outward tick on the right
  # (tick "out" direction, length ytick.major.size, width ytick.major.width).
  # legend.key.height = unit(1, "null") stretches the bar to the panel height.
  p <- p + ggplot2::theme(
    panel.grid = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.background = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    legend.key.width = grid::unit(15, "pt"),
    legend.key.height = grid::unit(1, "null"),
    legend.frame = ggplot2::element_blank(),
    legend.ticks = ggplot2::element_line(
      colour = .rb_col(DARK_GRAY), linewidth = .rb_lw(ctx$ytick.major.width)),
    legend.ticks.length = grid::unit(c(-ctx$ytick.major.size, 0), "pt")
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

#' Plot a hierarchically-clustered heatmap
#'
#' Port of `seaborn.clustermap`. Reorders rows/columns by hierarchical
#' clustering and draws dendrograms alongside the heatmap. Returns a patchwork
#' composition.
#'
#' @param data A matrix or data frame.
#' @param method Linkage method (default `"average"`).
#' @param metric Distance metric (default `"euclidean"`).
#' @param z_score Normalize rows (`0`) or columns (`1`) to z-scores.
#' @param standard_scale Scale rows (`0`) or columns (`1`) to `[0, 1]`.
#' @param row_cluster,col_cluster Whether to cluster rows / columns.
#' @param cmap Colormap (default `"rocket"`).
#' @param dendrogram_ratio Fraction of the figure used by the dendrograms.
#' @param ... Passed to [heatmap].
#' @return A `reaborn_plot` (patchwork).
#' @export
clustermap <- function(data, method = "average", metric = "euclidean",
                       z_score = NULL, standard_scale = NULL, row_cluster = TRUE,
                       col_cluster = TRUE, cmap = NULL, dendrogram_ratio = 0.2, ...) {
  if (!requireNamespace("patchwork", quietly = TRUE) ||
      !requireNamespace("ggdendro", quietly = TRUE)) {
    stop("clustermap() requires the 'patchwork' and 'ggdendro' packages.")
  }
  mat <- as.matrix(data)
  storage.mode(mat) <- "double"
  if (!is.null(z_score)) {
    mat <- if (z_score == 0) t(scale(t(mat))) else scale(mat)
  }
  if (!is.null(standard_scale)) {
    rng01 <- function(v) (v - min(v, na.rm = TRUE)) / (max(v, na.rm = TRUE) - min(v, na.rm = TRUE))
    mat <- if (standard_scale == 0) t(apply(mat, 1, rng01)) else apply(mat, 2, rng01)
  }

  row_ord <- seq_len(nrow(mat)); col_ord <- seq_len(ncol(mat))
  row_hc <- col_hc <- NULL
  if (row_cluster) { row_hc <- stats::hclust(stats::dist(mat, method = metric), method = method); row_ord <- row_hc$order }
  if (col_cluster) { col_hc <- stats::hclust(stats::dist(t(mat), method = metric), method = method); col_ord <- col_hc$order }
  mat <- mat[row_ord, col_ord, drop = FALSE]

  hm <- heatmap(mat, cmap = cmap, cbar = FALSE, ...)

  blank <- ggplot2::theme_void()
  col_dendro <- if (!is.null(col_hc)) {
    seg <- ggdendro::dendro_data(col_hc)$segments
    ggplot2::ggplot(seg) +
      ggplot2::geom_segment(ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend),
                            colour = RB_BOX_LINECOLOR, linewidth = .rb_lw(1)) +
      ggplot2::scale_x_continuous(expand = c(0, 0.5)) + blank
  } else patchwork::plot_spacer()
  row_dendro <- if (!is.null(row_hc)) {
    seg <- ggdendro::dendro_data(row_hc)$segments
    ggplot2::ggplot(seg) +
      ggplot2::geom_segment(ggplot2::aes(x = .data$y, y = .data$x, xend = .data$yend, yend = .data$xend),
                            colour = RB_BOX_LINECOLOR, linewidth = .rb_lw(1)) +
      ggplot2::scale_x_reverse() + ggplot2::scale_y_continuous(expand = c(0, 0.5)) + blank
  } else patchwork::plot_spacer()

  r <- dendrogram_ratio
  layout <- patchwork::plot_spacer() + col_dendro + row_dendro + hm +
    patchwork::plot_layout(ncol = 2, nrow = 2, widths = c(r, 1 - r), heights = c(r, 1 - r))
  reaborn_plot(layout, call = match.call())
}
