# Color palettes. Faithful ports of seaborn/palettes.py. Discrete palettes are
# returned as character vectors of hex codes (R-idiomatic and what ggplot scales
# consume); as_cmap=TRUE returns a `reaborn_cmap`, a function mapping [0,1] to hex.

QUAL_PALETTE_SIZES <- c(
  vapply(SEABORN_PALETTES, length, integer(1)),
  tab10 = 10L, Set2 = 8L
)

# ---- low-level color helpers ------------------------------------------------

# Convert a single matplotlib-style color to an RGB triple in [0, 1]. Accepts
# hex ("#rrggbb"), matplotlib/HTML color names, grayscale strings (".15"), and
# length-3 numeric vectors (already RGB in [0, 1]). Color NAMES are resolved
# through matplotlib's own table (.reaborn_mpl_colors) before falling back to
# R's col2rgb, because the two disagree (e.g. matplotlib "green" == #008000).
rb_color_to_rgb <- function(color) {
  if (is.numeric(color) && length(color) == 3) {
    return(as.numeric(color))
  }
  if (is.character(color) && length(color) == 1) {
    # Grayscale shorthand: ".15", "0.5", "1" -> gray of that level.
    if (grepl("^\\.?[0-9]+(\\.[0-9]+)?$", color)) {
      v <- as.numeric(color)
      if (!is.na(v) && v >= 0 && v <= 1) return(c(v, v, v))
    }
    if (grepl("^#[0-9A-Fa-f]{6}$", color)) {
      return(as.numeric(grDevices::col2rgb(color)) / 255)
    }
    hit <- .reaborn_mpl_colors[color]
    if (!is.na(hit)) {
      return(as.numeric(grDevices::col2rgb(unname(hit))) / 255)
    }
  }
  as.numeric(grDevices::col2rgb(color)) / 255
}

# Floor-index into a 256-row RGB LUT, reproducing matplotlib Colormap.__call__
# quantization: idx = clip(floor(x * 256), 0, 255).
.rb_lut256_lookup <- function(lut256, x) {
  idx <- pmin(pmax(floor(x * 256), 0), 255) + 1
  lut256[idx, , drop = FALSE]
}

# Build a 256-row RGB LUT from node colors via piecewise-linear interpolation at
# k/255 (mirrors matplotlib LinearSegmentedColormap.from_list internal _lut).
.rb_build_lut256 <- function(nodes) {
  .rb_blend_rgb(as.matrix(nodes), seq(0, 255) / 255)
}

# RGB triple in [0, 1] -> "#rrggbb", matching matplotlib.colors.to_hex rounding
# (round-half-to-even, which is base R's round()).
rb_rgb_to_hex <- function(rgb) {
  rgb <- pmin(pmax(rgb, 0), 1)
  sprintf("#%02x%02x%02x", round(rgb[1] * 255), round(rgb[2] * 255), round(rgb[3] * 255))
}

# Standard RGB -> HLS (mirrors Python colorsys.rgb_to_hls).
.rgb_to_hls <- function(r, g, b) {
  maxc <- max(r, g, b); minc <- min(r, g, b)
  l <- (minc + maxc) / 2
  if (minc == maxc) return(c(0, l, 0))
  d <- maxc - minc
  s <- if (l <= 0.5) d / (maxc + minc) else d / (2 - maxc - minc)
  rc <- (maxc - r) / d; gc <- (maxc - g) / d; bc <- (maxc - b) / d
  h <- if (r == maxc) bc - gc else if (g == maxc) 2 + rc - bc else 4 + gc - rc
  h <- (h / 6) %% 1
  c(h, l, s)
}

# Linear interpolation across a set of node colors (RGB rows), evenly spaced on
# [0, 1] -- matches matplotlib LinearSegmentedColormap.from_list sampling.
.rb_blend_rgb <- function(nodes, x) {
  k <- nrow(nodes)
  if (k == 1) return(matrix(nodes, nrow = length(x), ncol = 3, byrow = TRUE))
  pos <- x * (k - 1)
  lo <- pmin(floor(pos), k - 2)
  frac <- pos - lo
  lo <- lo + 1
  out <- matrix(0, length(x), 3)
  for (j in 1:3) {
    out[, j] <- nodes[lo, j] * (1 - frac) + nodes[lo + 1, j] * frac
  }
  out
}

#' A continuous reaborn colormap
#'
#' Constructed internally by palette functions when `as_cmap = TRUE`. It wraps a
#' 256-row RGB lookup table and is a function mapping values in `[0, 1]` to hex
#' colors via matplotlib's floor-index quantization. The hex LUT is stored in
#' `attr(., "colors")`.
#' @keywords internal
rb_make_cmap <- function(lut256, name = "reaborn") {
  lut256 <- as.matrix(lut256)
  hex <- apply(lut256, 1, rb_rgb_to_hex)
  f <- function(x) {
    idx <- pmin(pmax(floor(x * 256), 0), 255) + 1
    hex[idx]
  }
  structure(f, class = "reaborn_cmap", colors = hex, name = name)
}

# Build a 256-row LUT for a ListedColormap of discrete colors (matplotlib
# ListedColormap.__call__: colors[floor(x * n)]).
.rb_listed_lut256 <- function(node_rgb) {
  node_rgb <- as.matrix(node_rgb)
  n <- nrow(node_rgb)
  idx <- pmin(floor(((seq_len(256) - 0.5) / 256) * n), n - 1) + 1
  node_rgb[idx, , drop = FALSE]
}

#' @export
print.reaborn_cmap <- function(x, ...) {
  cat("<reaborn_cmap '", attr(x, "name"), "'> (256 colors)\n", sep = "")
  invisible(x)
}

# ---- desaturation -----------------------------------------------------------

#' Decrease the saturation of a color
#'
#' Port of `seaborn.desaturate`.
#' @param color A matplotlib-compatible color.
#' @param prop Proportion (in `[0, 1]`) of the original saturation to keep.
#' @return A hex color string.
#' @export
desaturate <- function(color, prop) {
  if (prop < 0 || prop > 1) stop("prop must be between 0 and 1")
  rgb <- rb_color_to_rgb(color)
  if (prop == 1) return(rb_rgb_to_hex(rgb))
  hls <- .rgb_to_hls(rgb[1], rgb[2], rgb[3])
  new <- .hls_to_rgb(hls[1], hls[2], hls[3] * prop)
  rb_rgb_to_hex(new)
}

#' Increase the saturation of a color to its maximum
#'
#' Port of `seaborn.saturate`.
#' @param color A matplotlib-compatible color.
#' @return A hex color string.
#' @export
saturate <- function(color) {
  rgb <- rb_color_to_rgb(color)
  hls <- .rgb_to_hls(rgb[1], rgb[2], rgb[3])
  rb_rgb_to_hex(.hls_to_rgb(hls[1], hls[2], 1))
}

#' Independently set the hue, lightness, and/or saturation of a color
#'
#' Port of `seaborn.set_hls_values`.
#' @param color A matplotlib-compatible color.
#' @param h,l,s New hue, lightness, saturation in `[0, 1]`, or `NULL` to keep.
#' @return A hex color string.
#' @export
set_hls_values <- function(color, h = NULL, l = NULL, s = NULL) {
  rgb <- rb_color_to_rgb(color)
  vals <- .rgb_to_hls(rgb[1], rgb[2], rgb[3])
  for (i in seq_along(list(h, l, s))) {
    val <- list(h, l, s)[[i]]
    if (!is.null(val)) vals[i] <- val
  }
  rb_rgb_to_hex(.hls_to_rgb(vals[1], vals[2], vals[3]))
}

# ---- the dispatcher ---------------------------------------------------------

#' Return a list of colors or a continuous colormap defining a palette
#'
#' Port of `seaborn.color_palette`. Possible `palette` values include the name
#' of a seaborn palette (`deep`, `muted`, `bright`, `pastel`, `dark`,
#' `colorblind`), a matplotlib colormap name, `"husl"`/`"hls"`, a cubehelix
#' shorthand (`"ch:..."`), `"light:<color>"`, `"dark:<color>"`,
#' `"blend:<c1>,<c2>"`, or a sequence of colors.
#'
#' @param palette `NULL`, a string, or a sequence of colors.
#' @param n_colors Number of colors. If `NULL`, depends on `palette`.
#' @param desat Proportion to desaturate each color by.
#' @param as_cmap If `TRUE`, return a continuous [reaborn_cmap].
#' @return A character vector of hex colors, or a `reaborn_cmap`.
#' @export
color_palette <- function(palette = NULL, n_colors = NULL, desat = NULL, as_cmap = FALSE) {
  pal <- NULL

  if (is.null(palette)) {
    pal <- SEABORN_PALETTES$deep
    if (is.null(n_colors)) n_colors <- length(pal)
  } else if (!is.character(palette) || length(palette) > 1) {
    # A sequence of colors.
    pal <- palette
    if (is.null(n_colors)) n_colors <- length(pal)
  } else {
    if (is.null(n_colors)) {
      n_colors <- if (palette %in% names(QUAL_PALETTE_SIZES)) {
        QUAL_PALETTE_SIZES[[palette]]
      } else 6L
    }
    if (palette %in% names(SEABORN_PALETTES)) {
      pal <- SEABORN_PALETTES[[palette]]
    } else if (palette == "hls") {
      pal <- hls_palette(n_colors, as_cmap = as_cmap)
    } else if (palette == "husl") {
      pal <- husl_palette(n_colors, as_cmap = as_cmap)
    } else if (tolower(palette) == "jet") {
      stop("No.")
    } else if (startsWith(palette, "ch:")) {
      pal <- do.call(cubehelix_palette,
                     c(list(n_colors = n_colors), .parse_cubehelix_args(palette),
                       list(as_cmap = as_cmap)))
    } else if (startsWith(palette, "light:")) {
      color <- sub("^light:", "", palette)
      reverse <- endsWith(color, "_r")
      if (reverse) color <- substr(color, 1, nchar(color) - 2)
      pal <- light_palette(color, n_colors, reverse = reverse, as_cmap = as_cmap)
    } else if (startsWith(palette, "dark:")) {
      color <- sub("^dark:", "", palette)
      reverse <- endsWith(color, "_r")
      if (reverse) color <- substr(color, 1, nchar(color) - 2)
      pal <- dark_palette(color, n_colors, reverse = reverse, as_cmap = as_cmap)
    } else if (startsWith(palette, "blend:")) {
      colors <- strsplit(sub("^blend:", "", palette), ",")[[1]]
      pal <- blend_palette(colors, n_colors, as_cmap = as_cmap)
    } else {
      pal <- mpl_palette(palette, n_colors, as_cmap = as_cmap)
    }
  }

  # hls/husl/ch/light/dark/blend/mpl already returned in final form.
  if (inherits(pal, "reaborn_cmap")) return(pal)
  if (as_cmap && (is.null(palette) || palette %in% names(SEABORN_PALETTES) ||
                  (!is.character(palette)))) {
    nodes <- t(vapply(pal, rb_color_to_rgb, numeric(3)))
    return(rb_make_cmap(.rb_listed_lut256(nodes), name = "seaborn"))
  }

  # Normalize to hex character vector.
  hex <- vapply(pal, function(c) {
    if (is.character(c) && grepl("^#[0-9A-Fa-f]{6}$", c)) toupper(c)
    else rb_rgb_to_hex(rb_color_to_rgb(c))
  }, character(1))

  if (!is.null(desat)) hex <- vapply(hex, desaturate, character(1), prop = desat)

  # Recycle to exactly n_colors.
  hex <- rep_len(hex, n_colors)
  unname(hex)
}

# ---- the individual palette generators --------------------------------------

#' @rdname color_palette
#' @param h,l,s Hue, lightness, saturation anchors in `[0, 1]`.
#' @export
hls_palette <- function(n_colors = 6, h = 0.01, l = 0.6, s = 0.65, as_cmap = FALSE) {
  if (as_cmap) n_colors <- 256
  hues <- seq(0, 1, length.out = as.integer(n_colors) + 1)[-(as.integer(n_colors) + 1)]
  hues <- hues + h
  hues <- hues %% 1
  hues <- hues - as.integer(hues)
  rgb <- lapply(hues, function(hi) .hls_to_rgb(hi, l, s))
  if (as_cmap) {
    return(rb_make_cmap(do.call(rbind, rgb), name = "hls"))
  }
  unname(vapply(rgb, rb_rgb_to_hex, character(1)))
}

#' @rdname color_palette
#' @export
husl_palette <- function(n_colors = 6, h = 0.01, s = 0.9, l = 0.65, as_cmap = FALSE) {
  if (as_cmap) n_colors <- 256
  hues <- seq(0, 1, length.out = as.integer(n_colors) + 1)[-(as.integer(n_colors) + 1)]
  hues <- hues + h
  hues <- hues %% 1
  hues <- hues * 359
  ss <- s * 99
  ll <- l * 99
  rgb <- lapply(hues, function(hi) pmin(pmax(.husl_to_rgb(hi, ss, ll), 0), 1))
  if (as_cmap) {
    return(rb_make_cmap(do.call(rbind, rgb), name = "husl"))
  }
  unname(vapply(rgb, rb_rgb_to_hex, character(1)))
}

# Internal RGB-space core for sequential (light/dark) palettes. Returns the two
# anchor node colors (gray, color) as a 2x3 RGB matrix, kept in full float
# precision so callers (notably diverging_palette) avoid premature 8-bit
# quantization. gray_l = 15 for dark, 95 for light.
.seq_palette_nodes <- function(color, reverse, input, gray_l) {
  rgb <- .input_color_to_rgb(color, input)
  husl <- .rgb_to_husl(rgb[1], rgb[2], rgb[3])
  gray_s <- 0.15 * husl[2]
  gray <- .input_color_to_rgb(c(husl[1], gray_s, gray_l), "husl")
  if (reverse) rbind(rgb, gray) else rbind(gray, rgb)
}

# Sample a sequential palette in RGB space (n x 3 float matrix).
.seq_palette_rgb <- function(color, n_colors, reverse, input, gray_l) {
  nodes <- .seq_palette_nodes(color, reverse, input, gray_l)
  lut256 <- .rb_build_lut256(nodes)
  .rb_lut256_lookup(lut256, seq(0, 1, length.out = as.integer(n_colors)))
}

#' @rdname color_palette
#' @param color Base color for the high end of a sequential palette.
#' @param reverse Reverse the direction of the blend.
#' @param input Color space of the input color: `"rgb"`, `"hls"`, or `"husl"`.
#' @export
dark_palette <- function(color, n_colors = 6, reverse = FALSE, as_cmap = FALSE, input = "rgb") {
  if (as_cmap) {
    return(rb_make_cmap(.rb_build_lut256(.seq_palette_nodes(color, reverse, input, 15)), "dark"))
  }
  m <- .seq_palette_rgb(color, n_colors, reverse, input, 15)
  unname(apply(m, 1, rb_rgb_to_hex))
}

#' @rdname color_palette
#' @export
light_palette <- function(color, n_colors = 6, reverse = FALSE, as_cmap = FALSE, input = "rgb") {
  if (as_cmap) {
    return(rb_make_cmap(.rb_build_lut256(.seq_palette_nodes(color, reverse, input, 95)), "light"))
  }
  m <- .seq_palette_rgb(color, n_colors, reverse, input, 95)
  unname(apply(m, 1, rb_rgb_to_hex))
}

#' @rdname color_palette
#' @param h_neg,h_pos Anchor hues (`[0, 359]`) for the negative and positive ends.
#' @param sep Size of the intermediate (center) region.
#' @param n Number of colors (when not returning a cmap).
#' @param center `"light"` or `"dark"` center.
#' @export
diverging_palette <- function(h_neg, h_pos, s = 75, l = 50, sep = 1, n = 6,
                              center = "light", as_cmap = FALSE) {
  gray_l <- if (center == "dark") 15 else 95
  n_half <- as.integer(128 - (sep %/% 2))
  # Keep the two halves in full-precision RGB (do NOT round-trip through hex);
  # this is what makes the blend match seaborn to the digit.
  neg <- .seq_palette_rgb(c(h_neg, s, l), n_half, reverse = TRUE, "husl", gray_l)
  pos <- .seq_palette_rgb(c(h_pos, s, l), n_half, reverse = FALSE, "husl", gray_l)
  mid_rgb <- if (center == "dark") c(0.133, 0.133, 0.133) else c(0.95, 0.95, 0.95)
  mid <- matrix(mid_rgb, nrow = sep, ncol = 3, byrow = TRUE)
  nodes <- rbind(neg, mid, pos)
  lut256 <- .rb_build_lut256(nodes)
  if (as_cmap) return(rb_make_cmap(lut256, "diverging"))
  m <- .rb_lut256_lookup(lut256, seq(0, 1, length.out = as.integer(n)))
  unname(apply(m, 1, rb_rgb_to_hex))
}

#' @rdname color_palette
#' @param colors A sequence of colors to blend between.
#' @export
blend_palette <- function(colors, n_colors = 6, as_cmap = FALSE, input = "rgb") {
  nodes <- t(vapply(colors, function(c) .input_color_to_rgb(c, input), numeric(3)))
  lut256 <- .rb_build_lut256(nodes)
  if (as_cmap) return(rb_make_cmap(lut256, name = "blend"))
  m <- .rb_lut256_lookup(lut256, seq(0, 1, length.out = as.integer(n_colors)))
  unname(apply(m, 1, rb_rgb_to_hex))
}

#' @rdname color_palette
#' @param name Name of a matplotlib colormap.
#' @export
mpl_palette <- function(name, n_colors = 6, as_cmap = FALSE) {
  if (name %in% names(MPL_QUAL_PALS)) {
    pal <- MPL_QUAL_PALS[[name]]
    idx <- seq_len(min(n_colors, length(pal)))
    if (as_cmap) return(rb_make_cmap(t(vapply(pal, rb_color_to_rgb, numeric(3))), name))
    return(rep_len(toupper(pal), n_colors))
  }
  lut <- .reaborn_cmaps[[name]]
  if (is.null(lut)) stop(sprintf("'%s' is not a bundled colormap name", name))
  lut256 <- t(vapply(lut, rb_color_to_rgb, numeric(3)))  # already 256 midpoint rows
  if (as_cmap) return(rb_make_cmap(lut256, name))
  bins <- seq(0, 1, length.out = as.integer(n_colors) + 2)
  bins <- bins[-c(1, length(bins))]
  m <- .rb_lut256_lookup(lut256, bins)
  unname(apply(m, 1, rb_rgb_to_hex))
}

#' @rdname color_palette
#' @param start,rot,gamma,hue,light,dark Cubehelix parameters (see seaborn).
#' @export
cubehelix_palette <- function(n_colors = 6, start = 0, rot = 0.4, gamma = 1.0,
                              hue = 0.8, light = 0.85, dark = 0.15,
                              reverse = FALSE, as_cmap = FALSE) {
  color_fn <- function(p0, p1) {
    function(x) {
      xg <- x^gamma
      a <- hue * xg * (1 - xg) / 2
      phi <- 2 * pi * (start / 3 + rot * x)
      xg + a * (p0 * cos(phi) + p1 * sin(phi))
    }
  }
  red_fn <- color_fn(-0.14861, 1.78277)
  grn_fn <- color_fn(-0.29227, -0.90649)
  blu_fn <- color_fn(1.97294, 0.0)
  sample_at <- function(x) {
    cbind(pmin(pmax(red_fn(x), 0), 1),
          pmin(pmax(grn_fn(x), 0), 1),
          pmin(pmax(blu_fn(x), 0), 1))
  }
  # matplotlib builds a 256-entry LinearSegmentedColormap LUT (functions sampled
  # at k/255), then floor-indexes it -- reproduce that exactly.
  lut256 <- sample_at(seq(0, 255) / 255)
  if (as_cmap) {
    x256 <- seq(light, dark, length.out = 256)
    if (reverse) x256 <- rev(x256)
    return(rb_make_cmap(.rb_lut256_lookup(lut256, x256), "seaborn_cubehelix"))
  }
  x <- seq(light, dark, length.out = as.integer(n_colors))
  m <- .rb_lut256_lookup(lut256, x)
  hex <- apply(m, 1, rb_rgb_to_hex)
  if (reverse) hex <- rev(hex)
  unname(hex)
}

.parse_cubehelix_args <- function(argstr) {
  if (startsWith(argstr, "ch:")) argstr <- substr(argstr, 4, nchar(argstr))
  reverse <- FALSE
  if (endsWith(argstr, "_r")) {
    reverse <- TRUE
    argstr <- substr(argstr, 1, nchar(argstr) - 2)
  }
  if (nchar(argstr) == 0) return(list(reverse = reverse))
  all_args <- trimws(strsplit(argstr, ",")[[1]])
  pos <- as.numeric(all_args[!grepl("=", all_args)])
  kv <- all_args[grepl("=", all_args)]
  kwarg_map <- c(s = "start", r = "rot", g = "gamma", h = "hue", l = "light", d = "dark")
  kwargs <- list()
  for (item in kv) {
    parts <- trimws(strsplit(item, "=")[[1]])
    key <- if (parts[1] %in% names(kwarg_map)) kwarg_map[[parts[1]]] else parts[1]
    kwargs[[key]] <- as.numeric(parts[2])
  }
  if (reverse) kwargs$reverse <- TRUE
  # Positional args map to start, rot, gamma, hue, light, dark in order.
  pos_names <- c("start", "rot", "gamma", "hue", "light", "dark")
  if (length(pos)) {
    for (i in seq_along(pos)) kwargs[[pos_names[i]]] <- pos[i]
  }
  kwargs
}

#' Change how single-letter color codes are interpreted
#'
#' Port of `seaborn.set_color_codes`. Returns (invisibly) the mapping from the
#' single-letter codes `b g r m y c k` to the colors of the given seaborn
#' palette, so reaborn helpers can resolve them like seaborn does.
#' @param palette One of `"deep"`, `"muted"`, `"pastel"`, `"bright"`, `"dark"`,
#'   `"colorblind"`.
#' @return Invisibly, the named character vector of code -> hex mappings.
#' @export
set_color_codes <- function(palette = "deep") {
  base <- sub("[0-9]+$", "", palette)
  pal <- color_palette(if (base %in% names(SEABORN_PALETTES)) base else palette, 10)
  # Order matches seaborn: blue, green, red, magenta, yellow, cyan from the
  # palette; black is fixed dark gray.
  codes <- c(b = pal[1], g = pal[3], r = pal[4], m = pal[5],
             y = pal[9], c = pal[10], k = "#1A1A1A")
  .reaborn$color_codes <- codes
  invisible(codes)
}

# Interpret an input color according to a color space, returning RGB in [0, 1].
.input_color_to_rgb <- function(color, input = "rgb") {
  if (identical(input, "hls")) return(.hls_to_rgb(color[1], color[2], color[3]))
  if (identical(input, "husl")) return(pmin(pmax(.husl_to_rgb(color[1], color[2], color[3]), 0), 1))
  rb_color_to_rgb(color)
}
