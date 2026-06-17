# Semantic mappings: translate seaborn's hue / size / style semantics into
# ggplot2 aesthetic columns + scales. Each resolver returns a list with:
#   $mapped  TRUE if the semantic is in use
#   $column  the (possibly re-typed) data column to map, or NULL
#   $aes     the ggplot aesthetic name ("colour", "size", "shape", ...)
#   $scale   a ggplot2 scale object (or NULL)
#   $type    "numeric" | "categorical"
#   $name    legend/title label

# Resolve the set of colors for a categorical hue, mirroring seaborn's
# HueMapping.categorical_mapping default logic.
rb_categorical_colors <- function(n, palette = NULL) {
  if (is.null(palette)) {
    active <- .reaborn_get("palette", "deep")
    cyc <- color_palette(active)
    if (n <= length(cyc)) color_palette(active, n) else husl_palette(n)
  } else if (is.character(palette) && length(palette) == 1L) {
    color_palette(palette, n)
  } else {
    rep_len(palette, n)
  }
}

#' @keywords internal
rb_resolve_hue <- function(values, name, type, palette = NULL,
                           order = NULL, norm = NULL, aes = "colour") {
  if (is.null(values)) return(list(mapped = FALSE))
  if (type == "numeric") {
    cmap <- color_palette(palette %||% "ch:", as_cmap = TRUE)
    lims <- norm %||% range(values, na.rm = TRUE)
    scale <- ggplot2::scale_colour_gradientn(
      colours = attr(cmap, "colors"), limits = lims, name = name
    )
    if (aes == "fill") {
      scale <- ggplot2::scale_fill_gradientn(
        colours = attr(cmap, "colors"), limits = lims, name = name
      )
    }
    list(mapped = TRUE, column = values, aes = aes, scale = scale,
         type = "numeric", name = name)
  } else {
    levels <- rb_categorical_order(values, order)
    cols <- rb_categorical_colors(length(levels), palette)
    lut <- stats::setNames(cols, levels)
    col <- factor(as.character(values), levels = levels)
    scale_fun <- if (aes == "fill") ggplot2::scale_fill_manual else ggplot2::scale_colour_manual
    list(mapped = TRUE, column = col, aes = aes,
         scale = scale_fun(values = lut, name = name, drop = FALSE),
         type = "categorical", name = name, levels = levels)
  }
}

#' @keywords internal
rb_resolve_size <- function(values, name, type, sizes = NULL, order = NULL,
                            norm = NULL, default_range = c(18, 72), aes = "size") {
  if (is.null(values)) return(list(mapped = FALSE))
  # Convert a seaborn size range to ggplot units: scatter `size` ranges are areas
  # (points^2); line `linewidth` ranges are widths (points).
  to_ggplot <- if (aes == "linewidth") .rb_lw else rb_area_to_size
  cont_scale <- if (aes == "linewidth") ggplot2::scale_linewidth_continuous else ggplot2::scale_size_continuous
  man_scale <- if (aes == "linewidth") ggplot2::scale_linewidth_manual else ggplot2::scale_size_manual

  if (type == "numeric") {
    rng <- to_ggplot(sizes %||% default_range)
    lims <- norm %||% range(values, na.rm = TRUE)
    list(mapped = TRUE, column = values, aes = aes,
         scale = cont_scale(range = rng, limits = lims, name = name),
         type = "numeric", name = name)
  } else {
    levels <- rb_categorical_order(values, order)
    n <- length(levels)
    base_rng <- sizes %||% default_range
    # seaborn assigns categorical sizes as evenly spaced steps, largest first.
    steps <- rev(seq(base_rng[1], base_rng[2], length.out = n))
    vals <- stats::setNames(to_ggplot(steps), levels)
    col <- factor(as.character(values), levels = levels)
    list(mapped = TRUE, column = col, aes = aes,
         scale = man_scale(values = vals, name = name),
         type = "categorical", name = name, levels = levels)
  }
}

#' @keywords internal
rb_resolve_style <- function(values, name, order = NULL, markers = TRUE,
                             dashes = FALSE, use_shape = TRUE) {
  if (is.null(values)) return(list(mapped = FALSE))
  levels <- rb_categorical_order(values, order)
  n <- length(levels)
  col <- factor(as.character(values), levels = levels)
  out <- list(mapped = TRUE, column = col, type = "categorical",
              name = name, levels = levels, scales = list(), aes = c())
  if (isTRUE(markers) || is.character(markers)) {
    shp <- if (is.character(markers)) markers else RB_MARKER_SHAPES[seq_len(n)]
    out$aes <- c(out$aes, shape = "shape")
    out$shape_scale <- ggplot2::scale_shape_manual(
      values = stats::setNames(shp, levels), name = name)
  }
  if (isTRUE(dashes)) {
    lty <- RB_LINETYPES[seq_len(n)]
    out$aes <- c(out$aes, linetype = "linetype")
    out$linetype_scale <- ggplot2::scale_linetype_manual(
      values = stats::setNames(lty, levels), name = name)
  }
  out
}

# Default filled-marker shapes mirroring seaborn's default marker cycle
# (o, X, s, D, ^, v, ...). ggplot uses solid filled equivalents.
RB_MARKER_SHAPES <- c(16, 4, 15, 18, 17, 25, 3, 8, 7, 9)
# Default ggplot linetypes approximating seaborn's dash cycle.
RB_LINETYPES <- c("solid", "22", "42", "44", "13", "1343", "73", "2262")

# seaborn point area (points^2) -> ggplot geom_point size (mm). Calibrated so a
# seaborn default s=36 renders at the same on-screen diameter.
rb_area_to_size <- function(area) {
  sqrt(area) / RB_SIZE_CALIB
}
# Calibration constant (diameter-points per ggplot-size), set in core-engine.R.
RB_SIZE_CALIB <- 2.0
