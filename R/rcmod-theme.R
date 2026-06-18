# Theme + context system. Faithful port of seaborn/rcmod.py, mapping seaborn's
# five styles and four contexts onto ggplot2 4.0 theme() elements. set_theme()
# mutates global state (the active ggplot theme + default color scales) the way
# seaborn mutates matplotlib rcParams, so plots pick up the look implicitly.

# Points-per-millimeter: matplotlib line/size constants are in points; ggplot
# element linewidths are in mm. Use ggplot2's own .pt so we don't drift.
RB_PT <- 72.27 / 25.4

# matplotlib points -> ggplot element linewidth (mm).
.rb_lw <- function(pt) pt / RB_PT

# Resolve a grayscale shorthand (".15") or named/hex color to a hex string.
.rb_col <- function(x) {
  if (is.character(x) && grepl("^\\.?[0-9]", x) && !grepl("^#", x)) {
    return(rb_rgb_to_hex(rb_color_to_rgb(x)))
  }
  if (identical(x, "white")) return("#FFFFFF")
  rb_rgb_to_hex(rb_color_to_rgb(x))
}

# ---- style definitions (verbatim from seaborn axes_style) -------------------
.RB_STYLES <- list(
  darkgrid  = list(facecolor = "#EAEAF2", edgecolor = "white", grid = TRUE,
                   gridcolor = "white",   ticks = FALSE),
  whitegrid = list(facecolor = "white",   edgecolor = ".8",    grid = TRUE,
                   gridcolor = ".8",      ticks = FALSE),
  dark      = list(facecolor = "#EAEAF2", edgecolor = "white", grid = FALSE,
                   gridcolor = "white",   ticks = FALSE),
  white     = list(facecolor = "white",   edgecolor = ".15",   grid = FALSE,
                   gridcolor = ".8",      ticks = FALSE),
  ticks     = list(facecolor = "white",   edgecolor = ".15",   grid = FALSE,
                   gridcolor = ".8",      ticks = TRUE)
)

DARK_GRAY <- ".15"   # text / tick / label color shared by all styles

# ---- context definitions (verbatim base, scaled like seaborn) ---------------
.RB_BASE_CONTEXT <- list(
  font.size = 12, axes.labelsize = 12, axes.titlesize = 12,
  xtick.labelsize = 11, ytick.labelsize = 11,
  legend.fontsize = 11, legend.title_fontsize = 12,
  axes.linewidth = 1.25, grid.linewidth = 1, lines.linewidth = 1.5,
  lines.markersize = 6, patch.linewidth = 1,
  xtick.major.width = 1.25, ytick.major.width = 1.25,
  xtick.minor.width = 1, ytick.minor.width = 1,
  xtick.major.size = 6, ytick.major.size = 6,
  xtick.minor.size = 4, ytick.minor.size = 4
)
.RB_CONTEXT_SCALING <- c(paper = 0.8, notebook = 1.0, talk = 1.5, poster = 2.0)
.RB_FONT_KEYS <- c("font.size", "axes.labelsize", "axes.titlesize",
                   "xtick.labelsize", "ytick.labelsize",
                   "legend.fontsize", "legend.title_fontsize")

#' Get the parameters that control the scaling of plot elements
#'
#' Port of `seaborn.plotting_context`. Returns a named list of resolved sizes.
#' @param context One of `"paper"`, `"notebook"`, `"talk"`, `"poster"`, or a list.
#' @param font_scale Separate scaling factor applied to the font sizes only.
#' @param rc Optional named list of overrides.
#' @return A named list of context parameters.
#' @export
plotting_context <- function(context = NULL, font_scale = 1, rc = NULL) {
  if (is.null(context)) context <- .reaborn_get("context", "notebook")
  if (is.list(context)) return(utils::modifyList(context, rc %||% list()))
  if (!context %in% names(.RB_CONTEXT_SCALING)) {
    stop(sprintf("context must be one of %s",
                 paste(names(.RB_CONTEXT_SCALING), collapse = ", ")))
  }
  scaling <- .RB_CONTEXT_SCALING[[context]]
  out <- lapply(.RB_BASE_CONTEXT, function(v) v * scaling)
  for (k in .RB_FONT_KEYS) out[[k]] <- out[[k]] * font_scale
  utils::modifyList(out, rc %||% list())
}

#' @rdname plotting_context
#' @export
set_context <- function(context = NULL, font_scale = 1, rc = NULL) {
  .reaborn$context <- context %||% "notebook"
  .reaborn$font_scale <- font_scale
  invisible(.rb_apply_global())
}

#' Get the parameters that control the general style of the plots
#'
#' Port of `seaborn.axes_style`. Returns the resolved style definition.
#' @param style One of `"darkgrid"`, `"whitegrid"`, `"dark"`, `"white"`, `"ticks"`.
#' @param rc Optional named list of overrides.
#' @return A named list describing the style.
#' @export
axes_style <- function(style = NULL, rc = NULL) {
  if (is.null(style)) style <- .reaborn_get("style", "darkgrid")
  if (is.list(style)) return(utils::modifyList(style, rc %||% list()))
  if (!style %in% names(.RB_STYLES)) {
    stop(sprintf("style must be one of %s", paste(names(.RB_STYLES), collapse = ", ")))
  }
  utils::modifyList(.RB_STYLES[[style]], rc %||% list())
}

#' @rdname axes_style
#' @export
set_style <- function(style = NULL, rc = NULL) {
  .reaborn$style <- style %||% "darkgrid"
  invisible(.rb_apply_global())
}

#' Build a ggplot2 theme replicating a seaborn style + context
#'
#' @param style A seaborn style name (see [axes_style]).
#' @param context A seaborn context name (see [plotting_context]).
#' @param font_scale Font scaling factor.
#' @param font Base font family.
#' @return A complete [ggplot2::theme] object.
#' @export
theme_seaborn <- function(style = "darkgrid", context = "notebook",
                          font_scale = 1, font = "sans") {
  st <- axes_style(style)
  ctx <- plotting_context(context, font_scale)

  text_col <- .rb_col(DARK_GRAY)
  facecol <- .rb_col(st$facecolor)
  gridcol <- .rb_col(st$gridcolor)
  edgecol <- .rb_col(st$edgecolor)
  grid_lw <- .rb_lw(ctx$grid.linewidth)
  axes_lw <- .rb_lw(ctx$axes.linewidth)

  grid_elem <- if (st$grid) {
    ggplot2::element_line(colour = gridcol, linewidth = grid_lw, linetype = "solid")
  } else {
    ggplot2::element_blank()
  }
  # darkgrid / dark have white "spines" (invisible against the white figure):
  # treat as no visible border. whitegrid / white / ticks draw a real frame.
  has_frame <- st$edgecolor %in% c(".8", ".15")
  border_elem <- if (has_frame) {
    ggplot2::element_rect(fill = NA, colour = edgecol, linewidth = axes_lw)
  } else {
    ggplot2::element_blank()
  }
  ticks_elem <- if (st$ticks) {
    ggplot2::element_line(colour = text_col, linewidth = .rb_lw(ctx$xtick.major.width))
  } else {
    ggplot2::element_blank()
  }

  base <- ggplot2::theme_grey(base_size = ctx$font.size, base_family = font)
  base + ggplot2::theme(
    text = ggplot2::element_text(colour = text_col, family = font),
    plot.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA),
    panel.background = ggplot2::element_rect(fill = facecol, colour = NA),
    panel.border = border_elem,
    panel.grid = grid_elem,
    # seaborn shows MAJOR gridlines only; matplotlib's tick locator (mirrored by
    # rb_mpl_breaks) places them densely enough that no minor grid is needed.
    panel.grid.minor = ggplot2::element_blank(),
    axis.line = ggplot2::element_blank(),
    axis.ticks = ticks_elem,
    axis.ticks.length = grid::unit(ctx$xtick.major.size, "pt"),
    axis.title = ggplot2::element_text(size = ctx$axes.labelsize, colour = text_col),
    axis.text = ggplot2::element_text(size = ctx$xtick.labelsize, colour = text_col),
    plot.title = ggplot2::element_text(size = ctx$axes.titlesize, colour = text_col),
    legend.text = ggplot2::element_text(size = ctx$legend.fontsize, colour = text_col),
    legend.title = ggplot2::element_text(size = ctx$legend.title_fontsize, colour = text_col),
    legend.key = ggplot2::element_blank(),
    legend.background = ggplot2::element_blank(),
    # seaborn facet titles are plain text above the panel, with no background box.
    strip.background = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(size = ctx$axes.labelsize, colour = text_col),
    complete = TRUE
  )
}

#' Set multiple theme parameters in one step
#'
#' Port of `seaborn.set_theme` (and its alias `set`). Sets the global look used
#' by subsequent reaborn (and ggplot2) plots.
#' @param context,style,palette,font,font_scale,color_codes,rc See seaborn.
#' @return Invisibly, the applied [ggplot2::theme].
#' @export
set_theme <- function(context = "notebook", style = "darkgrid", palette = "deep",
                      font = "sans", font_scale = 1, color_codes = TRUE, rc = NULL) {
  .reaborn$context <- context
  .reaborn$style <- style
  .reaborn$palette <- palette
  .reaborn$font <- font
  .reaborn$font_scale <- font_scale
  .reaborn$rc <- rc
  invisible(.rb_apply_global())
}

#' @rdname set_theme
#' @param ... Passed to [set_theme].
#' @export
set <- function(...) set_theme(...)

# Apply the current global state: register the theme and default color scales.
.rb_apply_global <- function() {
  thm <- theme_seaborn(
    style = .reaborn_get("style", "darkgrid"),
    context = .reaborn_get("context", "notebook"),
    font_scale = .reaborn_get("font_scale", 1),
    font = .reaborn_get("font", "sans")
  )
  ggplot2::theme_set(thm)
  pal <- color_palette(.reaborn_get("palette", "deep"))
  options(
    ggplot2.discrete.colour = pal,
    ggplot2.discrete.fill = pal,
    ggplot2.continuous.colour = function(...) ggplot2::scale_colour_gradientn(..., colours = attr(color_palette("rocket", as_cmap = TRUE), "colors")),
    ggplot2.continuous.fill = function(...) ggplot2::scale_fill_gradientn(..., colours = attr(color_palette("rocket", as_cmap = TRUE), "colors"))
  )
  invisible(thm)
}

#' Restore matplotlib/ggplot2 defaults
#'
#' Port of `seaborn.reset_defaults` / `seaborn.reset_orig`.
#' @return Invisibly `NULL`.
#' @export
reset_defaults <- function() {
  rm(list = ls(.reaborn), envir = .reaborn)
  ggplot2::theme_set(ggplot2::theme_grey())
  options(ggplot2.discrete.colour = NULL, ggplot2.discrete.fill = NULL,
          ggplot2.continuous.colour = NULL, ggplot2.continuous.fill = NULL)
  invisible(NULL)
}

#' @rdname reset_defaults
#' @export
reset_orig <- function() reset_defaults()

#' Set the matplotlib color cycle / ggplot default discrete palette
#'
#' Port of `seaborn.set_palette`.
#' @param palette A palette name or sequence (see [color_palette]).
#' @param n_colors,desat,color_codes See seaborn.
#' @return Invisibly `NULL`.
#' @export
set_palette <- function(palette, n_colors = NULL, desat = NULL, color_codes = FALSE) {
  .reaborn$palette <- palette
  pal <- color_palette(palette, n_colors, desat)
  options(ggplot2.discrete.colour = pal, ggplot2.discrete.fill = pal)
  invisible(NULL)
}

# Small helpers for the global state environment.
.reaborn_get <- function(key, default) {
  if (exists(key, envir = .reaborn, inherits = FALSE)) get(key, envir = .reaborn) else default
}

`%||%` <- function(a, b) if (is.null(a)) b else a
