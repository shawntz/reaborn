# Build R/sysdata.rda: internal (non-exported) package data, generated from the
# ground-truth JSON produced by data-raw/extract-constants.py. Run from the
# package root after re-extracting constants:
#
#     Rscript data-raw/make-sysdata.R
#
# Currently embeds the continuous seaborn / matplotlib colormaps as 256-color
# hex lookup tables (too large and opaque to hand-write as R literals).

js <- jsonlite::fromJSON(
  "inst/extdata/seaborn_constants.json",
  simplifyVector = TRUE
)

# Named list of 256-element hex character vectors (bin-midpoint sampled, so
# floor(x*256) indexing reproduces matplotlib's cmap(x) exactly).
.reaborn_cmaps <- c(
  as.list(js$cmaps), # rocket, mako, flare, crest, icefire, vlag (+ _r)
  as.list(js$mpl_cmaps) # magma, inferno, plasma, viridis, cividis, coolwarm, ...
)
# Drop any NULL/empty entries defensively.
.reaborn_cmaps <- .reaborn_cmaps[
  vapply(.reaborn_cmaps, length, integer(1)) == 256L
]

# matplotlib named-color table: single-letter BASE_COLORS, the 148 CSS4 names,
# and the tab: colors. reaborn resolves color names through this (NOT R's
# col2rgb) because they disagree -- famously matplotlib "green"/"g" is #008000.
.reaborn_mpl_colors <- local({
  base <- unlist(js$named_colors$base)
  css4 <- unlist(js$named_colors$css4)
  tabc <- unlist(js$named_colors$tab)
  all <- c(base, css4, tabc)
  toupper(all[!duplicated(names(all))])
})

# A small bundle of validation fixtures (kde factor, hist edges, bootstrap, etc.)
# kept internal so tests can assert reaborn matches seaborn without re-running py.
.reaborn_fixtures <- list(
  kde = js$kde,
  hist = js$hist,
  bootstrap = js$bootstrap,
  scatter_sizes = js$scatter_sizes,
  rc_context_raw = js$rc_context_raw,
  rc_style = js$rc_style,
  husl = js$husl,
  palettes = js$palettes,
  pal_husl = js$pal_husl,
  pal_hls = js$pal_hls,
  pal_cubehelix_default = js$pal_cubehelix_default
)

# Categorical column orderings per bundled dataset, so reaborn restores the same
# ordered factors seaborn uses (ggplot2 would otherwise alphabetize).
.reaborn_dataset_orders <- local({
  res <- list()
  for (ds in names(js$dataset_orders)) {
    info <- js$dataset_orders[[ds]]
    ord <- info$orders
    keep <- list()
    for (col in names(ord)) {
      lv <- ord[[col]]
      if (!is.null(lv) && length(lv)) keep[[col]] <- as.character(lv)
    }
    if (length(keep)) res[[ds]] <- keep
  }
  res
})

save(
  .reaborn_cmaps,
  .reaborn_fixtures,
  .reaborn_mpl_colors,
  .reaborn_dataset_orders,
  file = "R/sysdata.rda",
  version = 3,
  compress = "xz"
)

cat(
  "Wrote R/sysdata.rda with",
  length(.reaborn_cmaps),
  "colormaps,",
  length(.reaborn_fixtures),
  "fixture groups,",
  length(.reaborn_mpl_colors),
  "named colors, and",
  length(.reaborn_dataset_orders),
  "dataset orderings\n"
)
