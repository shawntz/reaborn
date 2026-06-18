# Fidelity harness: render the 14 reaborn halves of the man/figures/compare-*.png
# side-by-side comparison figures, through the public reaborn API.
#
# These are the reaborn-only renders; the matching seaborn reference halves are
# committed, frozen pixels in tests/fidelity/seaborn/ (seaborn is the fixed
# ground truth for a fidelity figure, so it must NOT drift when reaborn changes).
# data-raw/make-gallery.py composites each reaborn panel beside its frozen
# seaborn partner into man/figures/compare-<name>.png.
#
# Run from the package root:
#     Rscript tests/fidelity/render_reaborn_panels.R
#
# Each panel is rendered at the SAME pixel size as its frozen seaborn partner so
# make-gallery.py composites them without aspect drift. The sizes below were read
# off the committed figures; do not change them without re-checking the seaborn
# reference dimensions in tests/fidelity/seaborn/.

# Use the installed package in CI; fall back to load_all() for local dev so an
# uninstalled working tree still renders.
if (nzchar(system.file(package = "reaborn"))) {
  suppressPackageStartupMessages(library(reaborn))
} else {
  suppressMessages(pkgload::load_all(quiet = TRUE))
}

OUT <- "tests/fidelity/out"
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

# Prefer ragg's PNG device: it renders identically across platforms (so CI
# doesn't churn the committed figures on every runner-image bump) and is the
# device the package Suggests. Falls back to grDevices when ragg isn't installed.
PNG_DEVICE <- if (requireNamespace("ragg", quietly = TRUE)) {
  ragg::agg_png
} else {
  NULL
}

save_panel <- function(p, file, width, height) {
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
tips <- load_dataset("tips")

# --- Relational -------------------------------------------------------------
save_panel(
  scatterplot(pen, x = "bill_length_mm", y = "bill_depth_mm", hue = "species") +
    move_legend(loc = "lower left"),
  "reaborn_scatter_hue.png",
  6,
  5
)
save_panel(
  lineplot(fmri, x = "timepoint", y = "signal", hue = "event"),
  "reaborn_line_hue.png",
  6,
  5
)
save_panel(
  relplot(
    fmri,
    x = "timepoint",
    y = "signal",
    hue = "event",
    col = "region",
    kind = "line"
  ),
  "reaborn_relplot_line.png", 8, 4
)

# --- Distributions ----------------------------------------------------------
save_panel(
  histplot(pen, x = "flipper_length_mm"),
  "reaborn_hist.png", 6, 5
)
save_panel(
  histplot(pen, x = "flipper_length_mm", hue = "species", multiple = "stack"),
  "reaborn_hist_stack.png", 6.5, 5
)
save_panel(
  kdeplot(pen, x = "flipper_length_mm", hue = "species", fill = TRUE),
  "reaborn_kde.png", 6.5, 5
)
save_panel(
  ecdfplot(pen, x = "bill_length_mm", hue = "species"),
  "reaborn_ecdf.png", 6.5, 5
)
save_panel(
  displot(pen, x = "flipper_length_mm", col = "species"),
  "reaborn_displot.png", 9, 3.5
)

# --- Categorical ------------------------------------------------------------
save_panel(
  boxplot(tips, x = "day", y = "total_bill"),
  "reaborn_box.png", 6, 5
)
save_panel(
  boxplot(tips, x = "day", y = "total_bill", hue = "smoker"),
  "reaborn_box_hue.png", 6.5, 5
)
save_panel(
  boxenplot(pen, x = "species", y = "body_mass_g"),
  "reaborn_boxen.png",
  6,
  5
)
save_panel(
  violinplot(tips, x = "day", y = "total_bill"),
  "reaborn_violin.png",
  6,
  5
)

# --- Regression -------------------------------------------------------------
save_panel(regplot(tips, x = "total_bill", y = "tip"), "reaborn_reg.png", 6, 5)

# --- Matrix -----------------------------------------------------------------
mat <- tapply(fl$passengers, list(fl$month, fl$year), function(x) x[1])
save_panel(
  heatmap(mat, annot = TRUE, fmt = "d", linewidths = 0.5),
  "reaborn_heatmap.png",
  8,
  6
)

cat("DONE\n")
