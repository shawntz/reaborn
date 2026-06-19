#!/usr/bin/env Rscript
# Generate the reaborn hex sticker -> man/figures/logo.png
#
# A pointy-top regular hexagon (the standard R/tidyverse orientation) styled as a
# seaborn homage: the seaborn "darkgrid" lavender panel with white gridlines, three
# overlapping translucent KDE density humps in the signature "deep" palette, and the
# two-tone "reaborn" wordmark. Pure base R: grid + grDevices + ragg (native transparency).
#
# Run from the package root:  Rscript data-raw/make-logo.R

suppressMessages({
  library(grid)
  library(ragg)
})

# ---- Brand colors (exact, matching the package constants) -------------------
col_fill <- "#EAEAF2" # seaborn darkgrid panel facecolor (light lavender-grey)
col_grid <- "#FFFFFF" # gridlines
col_blue <- "#4C72B0" # deep palette: blue
col_orange <- "#DD8452" # deep palette: orange
col_green <- "#55A868" # deep palette: green
col_ink <- "#262626" # dark text
col_inner <- "#7E97C4" # lighter inner border stroke (for depth)

# ---- Renderer ---------------------------------------------------------------
# All sizes are parametrized as fractions of canvas width, so the artwork scales
# to any resolution. The hexagon is inset slightly from the canvas edge so its
# full border renders without being clipped by the canvas bounds.
render_hex <- function(file, W) {
  H <- round(W * 2 / sqrt(3)) # pointy-top hex: width = R*sqrt(3), height = 2R

  agg_png(file, width = W, height = H, units = "px", background = "transparent")
  on.exit(dev.off(), add = TRUE)
  grid.newpage()

  # ---- Hex geometry (pointy-top), inset from the canvas edge ----------------
  # Base vertices of a regular pointy-top hex filling a sqrt(3):2 canvas, in NPC.
  hx0 <- c(0.5, 1.0, 1.0, 0.5, 0.0, 0.0)
  hy0 <- c(1.0, 0.75, 0.25, 0.0, 0.25, 0.75)
  inset <- 0.965 # shrink toward center so the border isn't clipped at the edge
  hx <- 0.5 + (hx0 - 0.5) * inset
  hy <- 0.5 + (hy0 - 0.5) * inset

  border_lwd <- W * 0.020
  inner_lwd <- W * 0.006

  # ---- Hex fill -------------------------------------------------------------
  grid.polygon(x = hx, y = hy, gp = gpar(fill = col_fill, col = NA))

  # ---- Clip everything below to the hexagon ---------------------------------
  pushViewport(viewport(clip = polygonGrob(x = hx, y = hy)))

  # ---- seaborn-style white gridlines (subtle, behind the KDEs) --------------
  grid_lwd <- W * 0.004
  for (gy in seq(0.12, 0.88, by = 0.13)) {
    grid.lines(
      c(0, 1),
      c(gy, gy),
      gp = gpar(col = col_grid, lwd = grid_lwd, alpha = 0.9)
    )
  }
  for (gx in seq(0.12, 0.88, by = 0.13)) {
    grid.lines(
      c(gx, gx),
      c(0, 1),
      gp = gpar(col = col_grid, lwd = grid_lwd, alpha = 0.9)
    )
  }

  # ---- KDE density humps -----------------------------------------------------
  baseline <- 0.43
  gauss <- function(x, mu, sig) exp(-0.5 * ((x - mu) / sig)^2)
  xs <- seq(0.04, 0.96, length.out = 400)

  draw_kde <- function(mu, sig, amp, fill) {
    yy <- baseline + amp * gauss(xs, mu, sig)
    grid.polygon(
      x = c(xs, rev(xs)),
      y = c(yy, rep(baseline, length(xs))),
      gp = gpar(fill = fill, col = NA, alpha = 0.55)
    )
    grid.lines(xs, yy, gp = gpar(col = fill, lwd = W * 0.007)) # crisp top stroke
  }

  amp <- 0.29
  draw_kde(mu = 0.34, sig = 0.115, amp = amp, fill = col_blue)
  draw_kde(mu = 0.50, sig = 0.130, amp = amp * 1.06, fill = col_orange)
  draw_kde(mu = 0.66, sig = 0.115, amp = amp * 0.98, fill = col_green)

  grid.lines(
    c(0.10, 0.90),
    c(baseline, baseline),
    gp = gpar(col = col_ink, lwd = W * 0.004, alpha = 0.45)
  )

  popViewport() # end clip

  # ---- Wordmark "reaborn" (two-tone: re=ink, aborn=blue) --------------------
  fam <- "Avenir Next"
  wm_fs <- W * 0.135
  wm_y <- 0.225
  gp_re <- gpar(col = col_ink, fontfamily = fam, fontface = 2, fontsize = wm_fs)
  gp_ab <- gpar(
    col = col_blue,
    fontfamily = fam,
    fontface = 2,
    fontsize = wm_fs
  )
  re_w <- convertWidth(
    grobWidth(textGrob("re", gp = gp_re)),
    "npc",
    valueOnly = TRUE
  )
  ab_w <- convertWidth(
    grobWidth(textGrob("aborn", gp = gp_ab)),
    "npc",
    valueOnly = TRUE
  )
  x0 <- 0.5 - (re_w + ab_w) / 2
  grid.text("re", x = x0, y = wm_y, just = c("left", "center"), gp = gp_re)
  grid.text(
    "aborn",
    x = x0 + re_w,
    y = wm_y,
    just = c("left", "center"),
    gp = gp_ab
  )

  # ---- Hex border (on top) --------------------------------------------------
  grid.polygon(
    x = hx,
    y = hy,
    gp = gpar(fill = NA, col = col_inner, lwd = inner_lwd)
  )
  grid.polygon(
    x = hx,
    y = hy,
    gp = gpar(fill = NA, col = col_blue, lwd = border_lwd)
  )
}

# ---- Write the package logo -------------------------------------------------
out <- file.path("man", "figures", "logo.png")
if (!dir.exists(dirname(out))) {
  dir.create(dirname(out), recursive = TRUE)
}
render_hex(out, W = 1200)
cat("wrote", normalizePath(out), "\n")
