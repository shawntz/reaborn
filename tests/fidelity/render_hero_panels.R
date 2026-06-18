# Hero-collage harness: render the six reaborn-only showcase panels that
# data-raw/make-gallery.py composites into man/figures/hero-collage.png.
#
# These are reaborn plots only (no seaborn reference), so this needs just R +
# the package -- no Python/seaborn env. The KDE panel goes through the public
# kdeplot() so the collage always reflects the current hue-legend styling.
#
# Run from the package root:
#     Rscript tests/fidelity/render_hero_panels.R
#
# Each panel is rendered at 6.5x5in @ 100dpi on white so make-gallery.py can
# scale them to a uniform grid height without aspect drift.

# Use the installed package in CI; fall back to load_all() for local dev.
if (nzchar(system.file(package = "reaborn"))) {
  suppressPackageStartupMessages(library(reaborn))
} else {
  suppressMessages(pkgload::load_all(quiet = TRUE))
}

OUT <- "tests/fidelity/out"
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

# Prefer ragg's PNG device when available: it renders identically across
# platforms (so CI doesn't churn the committed collage on every runner-image
# bump) and is the device the package Suggests. Falls back to the default
# grDevices device when ragg isn't installed.
PNG_DEVICE <- if (requireNamespace("ragg", quietly = TRUE)) {
  ragg::agg_png
} else {
  NULL
}

save_panel <- function(p, file, width = 6.5, height = 5) {
  ggplot2::ggsave(
    file.path(OUT, file),
    p,
    width = width,
    height = height,
    dpi = 100,
    bg = "white",
    device = PNG_DEVICE
  )
  cat("wrote", file, "\n")
}

pen <- load_dataset("penguins")
fmri <- load_dataset("fmri")
fl <- load_dataset("flights")

# 1. scatter (hue) -------------------------------------------------------------
save_panel(
  scatterplot(
    data = pen,
    x = "bill_length_mm",
    y = "bill_depth_mm",
    hue = "species"
  ),
  "reaborn_scatter_hue.png"
)

# 2. violin --------------------------------------------------------------------
save_panel(
  violinplot(
    data = pen,
    x = "species",
    y = "body_mass_g",
    hue = "species",
    legend = FALSE
  ),
  "reaborn_violin.png"
)

# 3. KDE (filled, hue legend) -- the panel the refresh is really about ---------
save_panel(
  kdeplot(data = pen, x = "flipper_length_mm", hue = "species", fill = TRUE),
  "reaborn_kde.png"
)

# 4. heatmap (flights passengers, month x year) --------------------------------
mat <- tapply(fl$passengers, list(fl$month, fl$year), function(x) x[1])
save_panel(heatmap(mat), "reaborn_heatmap.png")

# 5. line (hue) ----------------------------------------------------------------
save_panel(
  lineplot(data = fmri, x = "timepoint", y = "signal", hue = "event"),
  "reaborn_line_hue.png"
)

# 6. boxen ---------------------------------------------------------------------
save_panel(
  boxenplot(
    data = pen,
    x = "species",
    y = "body_mass_g",
    hue = "species",
    legend = FALSE
  ),
  "reaborn_boxen.png"
)

cat("DONE\n")
