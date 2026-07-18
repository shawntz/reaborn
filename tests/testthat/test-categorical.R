# Categorical + regression + heatmap builders and key behaviors.

test_that("categorical fills are desaturated to 0.75", {
  # desaturate(deep[0], .75) == #5875A4 (seaborn-verified)
  expect_identical(
    toupper(desaturate(color_palette("deep")[1], 0.75)),
    "#5875A4"
  )
})

test_that("categorical orient inference and ordering", {
  tips <- load_dataset("tips")
  sv <- reaborn:::rb_cat_setup(tips, x = "day", y = "total_bill")
  expect_identical(sv$orient, "v")
  expect_identical(sv$cat_levels, c("Thur", "Fri", "Sat", "Sun"))
  sh <- reaborn:::rb_cat_setup(tips, x = "total_bill", y = "day")
  expect_identical(sh$orient, "h")
})

test_that("boxplot / countplot / stripplot build", {
  tips <- load_dataset("tips")
  expect_no_error(ggplot2::ggplot_build(boxplot(
    data = tips,
    x = "day",
    y = "total_bill"
  )))
  expect_no_error(ggplot2::ggplot_build(boxplot(
    data = tips,
    x = "day",
    y = "total_bill",
    hue = "smoker"
  )))
  expect_no_error(ggplot2::ggplot_build(countplot(
    data = tips,
    x = "day",
    hue = "smoker"
  )))
  expect_no_error(ggplot2::ggplot_build(stripplot(
    data = tips,
    x = "day",
    y = "total_bill",
    hue = "smoker",
    dodge = TRUE
  )))
})

test_that("countplot(y=) draws horizontal bars of the categorical counts", {
  tips <- load_dataset("tips")
  d <- ggplot2::ggplot_build(countplot(data = tips, y = "day"))$data[[1]]
  # One bar per day category, count on the x (value) axis, categories on y.
  expect_identical(nrow(d), 4L)
  expect_equal(sort(round(d$x)), sort(unname(as.numeric(table(tips$day)))))
  expect_equal(sort(as.numeric(d$y)), c(1, 2, 3, 4))
  p <- countplot(data = tips, y = "day")
  expect_identical(p$labels$x, "Count")
  expect_identical(p$labels$y, "day")
})

test_that("countplot orientation follows the assigned variable", {
  tips <- load_dataset("tips")
  day_counts <- sort(unname(as.numeric(table(tips$day))))
  # The assigned axis is categorical; a conflicting `orient` is overridden so
  # bars never collapse into a single empty category (matches seaborn.countplot).
  xd <- ggplot2::ggplot_build(countplot(
    data = tips,
    x = "day",
    orient = "h"
  ))$data[[1]]
  expect_identical(nrow(xd), 4L)
  expect_equal(sort(round(xd$y)), day_counts) # counts stay on y => vertical
  yd <- ggplot2::ggplot_build(countplot(
    data = tips,
    y = "day",
    orient = "v"
  ))$data[[1]]
  expect_identical(nrow(yd), 4L)
  expect_equal(sort(round(yd$x)), day_counts) # counts stay on x => horizontal
  # Passing both x and y is ambiguous for a count plot.
  expect_error(
    countplot(data = tips, x = "day", y = "total_bill"),
    "both `x` and `y`"
  )
})

test_that("barplot heights equal group means and CI brackets them", {
  tips <- load_dataset("tips")
  s <- reaborn:::rb_cat_setup(tips, x = "day", y = "total_bill")
  agg <- reaborn:::rb_cat_aggregate(s, "mean", list("ci", 95), 500, 0)
  means <- tapply(tips$total_bill, tips$day, mean)
  for (d in names(means)) {
    row <- agg[as.character(agg$.cat) == d, ]
    expect_equal(row$estimate, unname(means[[d]]), tolerance = 1e-9)
    expect_true(row$ymin < row$estimate && row$estimate < row$ymax)
  }
})

test_that("pointplot and catplot build (incl. faceting)", {
  tips <- load_dataset("tips")
  expect_no_error(ggplot2::ggplot_build(pointplot(
    data = tips,
    x = "day",
    y = "total_bill",
    hue = "sex"
  )))
  expect_no_error(ggplot2::ggplot_build(catplot(
    data = tips,
    x = "day",
    y = "total_bill",
    col = "time",
    kind = "box"
  )))
  expect_no_error(ggplot2::ggplot_build(catplot(
    data = tips,
    x = "day",
    y = "total_bill",
    hue = "sex",
    col = "time",
    kind = "bar"
  )))
})

test_that("manual `+ facet_wrap()` re-aggregates a barplot per panel (#73)", {
  penguins <- load_dataset("penguins")
  p <- barplot(data = penguins, x = "sex", y = "body_mass_g") +
    ggplot2::facet_wrap(~species)
  expect_no_error(ggplot2::ggplot_build(p))
  # The facet column is carried into the (re-aggregated) plot data ...
  expect_true("species" %in% names(p$data))
  # ... with one bar per sex x species, not one shared full-data summary.
  expect_identical(nrow(p$data), 6L)
  expect_identical(length(unique(round(p$data$estimate))), 6L)

  # Per-panel means match a within-species aggregation done by hand.
  by_hand <- tapply(
    penguins$body_mass_g,
    list(penguins$species, penguins$sex),
    mean,
    na.rm = TRUE
  )
  for (i in seq_len(nrow(p$data))) {
    row <- p$data[i, ]
    expect_equal(
      row$estimate,
      by_hand[as.character(row$species), as.character(row$.cat)],
      tolerance = 1e-9
    )
  }
})

test_that("manual facets re-aggregate to match catplot() estimates", {
  penguins <- load_dataset("penguins")
  manual <- barplot(data = penguins, x = "sex", y = "body_mass_g") +
    ggplot2::facet_wrap(~species)
  viacat <- catplot(
    data = penguins,
    x = "sex",
    y = "body_mass_g",
    col = "species",
    kind = "bar"
  )
  key <- function(d) paste(d$species, d$.cat)
  m <- manual$data[order(key(manual$data)), ]
  v <- viacat$data[order(key(viacat$data)), ]
  expect_equal(m$estimate, v$estimate, tolerance = 1e-9)
})

test_that("manual facets build for every categorical kind", {
  penguins <- load_dataset("penguins")
  tips <- load_dataset("tips")
  expect_no_error(suppressWarnings(ggplot2::ggplot_build(
    boxplot(data = penguins, x = "sex", y = "body_mass_g") +
      ggplot2::facet_wrap(~species)
  )))
  expect_no_error(ggplot2::ggplot_build(
    countplot(data = penguins, x = "species") + ggplot2::facet_wrap(~sex)
  ))
  expect_no_error(ggplot2::ggplot_build(
    pointplot(data = tips, x = "day", y = "total_bill") +
      ggplot2::facet_wrap(~time)
  ))
  expect_no_error(ggplot2::ggplot_build(
    stripplot(data = penguins, x = "sex", y = "body_mass_g") +
      ggplot2::facet_wrap(~species)
  ))
  # facet_grid (two variables) is honored too.
  expect_no_error(ggplot2::ggplot_build(
    barplot(data = penguins, x = "species", y = "body_mass_g") +
      ggplot2::facet_grid(sex ~ island)
  ))
})

test_that("components added before a facet survive the re-aggregation", {
  penguins <- load_dataset("penguins")
  suppressWarnings({
    p <- barplot(data = penguins, x = "sex", y = "body_mass_g") +
      ggplot2::scale_y_continuous(limits = c(0, 9000)) +
      ggplot2::facet_wrap(~species)
    b <- ggplot2::ggplot_build(p)
  })
  # The user's y limits (not barplot's default scale) drive the panel range.
  expect_gt(b$layout$panel_params[[1]]$y.range[2], 8000)
  # The re-aggregation preserves the original seaborn-style call, not do.call().
  expect_identical(attr(p, "reaborn_call")[[1]], as.name("barplot"))
})

test_that("faceted countplot normalizes proportion/percent per panel", {
  penguins <- load_dataset("penguins")
  # Each panel's proportions should sum to 1 (per-facet total), not the panel's
  # share of the global total.
  pp <- countplot(data = penguins, x = "sex", stat = "proportion") +
    ggplot2::facet_wrap(~species)
  per_panel <- as.numeric(tapply(pp$data$value, pp$data$species, sum))
  expect_equal(per_panel, rep(1, length(per_panel)), tolerance = 1e-9)

  # Percent panels sum to 100; matches the catplot() faceting path.
  pc <- catplot(
    data = penguins,
    x = "sex",
    col = "species",
    kind = "count",
    stat = "percent"
  )
  pc_panel <- as.numeric(tapply(pc$data$value, pc$data$species, sum))
  expect_equal(pc_panel, rep(100, length(pc_panel)), tolerance = 1e-9)

  # Non-faceted normalization is unchanged (still a single global total).
  pn <- countplot(data = penguins, x = "species", stat = "proportion")
  expect_equal(sum(pn$data$value), 1, tolerance = 1e-9)
})

test_that("rb_facet_vars extracts columns from wrap and grid facets", {
  expect_identical(
    reaborn:::rb_facet_vars(ggplot2::facet_wrap(~species)),
    "species"
  )
  expect_setequal(
    reaborn:::rb_facet_vars(ggplot2::facet_grid(sex ~ island)),
    c("sex", "island")
  )
})

test_that("rb_facet_vars resolves the .data[[...]] pronoun syntax", {
  col <- "species"
  # String index, variable index, and $ variant all resolve to the column.
  expect_identical(
    reaborn:::rb_facet_vars(ggplot2::facet_wrap(ggplot2::vars(.data[[
      "species"
    ]]))),
    "species"
  )
  expect_identical(
    reaborn:::rb_facet_vars(ggplot2::facet_wrap(ggplot2::vars(.data[[col]]))),
    "species"
  )
  expect_setequal(
    reaborn:::rb_facet_vars(ggplot2::facet_grid(
      .data[["sex"]] ~ .data[["island"]]
    )),
    c("sex", "island")
  )
})

test_that("manual facets re-aggregate with .data[[...]] facet syntax", {
  penguins <- load_dataset("penguins")
  col <- "species"
  # facet_wrap with a variable index carries the resolved column into the
  # re-aggregated data (one bar per sex x species, not one shared summary).
  pw <- barplot(data = penguins, x = "sex", y = "body_mass_g") +
    ggplot2::facet_wrap(ggplot2::vars(.data[[col]]))
  expect_no_error(ggplot2::ggplot_build(pw))
  expect_true("species" %in% names(pw$data))
  expect_identical(nrow(pw$data), 6L)

  # facet_grid with .data[["..."]] on both axes.
  pg <- barplot(data = penguins, x = "species", y = "body_mass_g") +
    ggplot2::facet_grid(.data[["sex"]] ~ .data[["island"]])
  expect_no_error(ggplot2::ggplot_build(pg))
  expect_true(all(c("sex", "island") %in% names(pg$data)))
})

test_that("regplot / residplot / lmplot build with bootstrap band", {
  tips <- load_dataset("tips")
  p <- regplot(data = tips, x = "total_bill", y = "tip", seed = 0)
  b <- ggplot2::ggplot_build(p)
  geoms <- vapply(b$plot$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("Ribbon", geoms))) # bootstrap CI band
  expect_true(any(grepl("Line", geoms)))
  expect_no_error(ggplot2::ggplot_build(residplot(
    data = tips,
    x = "total_bill",
    y = "tip"
  )))
  expect_no_error(ggplot2::ggplot_build(lmplot(
    data = tips,
    x = "total_bill",
    y = "tip",
    hue = "smoker",
    col = "time"
  )))
})

test_that("regression fit matches a plain lm", {
  tips <- load_dataset("tips")
  grid <- seq(min(tips$total_bill), max(tips$total_bill), length.out = 100)
  got <- reaborn:::.rb_reg_fit(tips$total_bill, tips$tip, grid, order = 1)
  fit <- lm(tip ~ total_bill, tips)
  want <- predict(fit, data.frame(total_bill = grid))
  expect_equal(got, unname(want), tolerance = 1e-9)
})

test_that("heatmap builds; relative_luminance + fmt are correct", {
  fl <- load_dataset("flights")
  mat <- tapply(fl$passengers, list(fl$month, fl$year), function(x) x[1])
  expect_no_error(ggplot2::ggplot_build(heatmap(mat, annot = TRUE, fmt = "d")))
  expect_no_error(ggplot2::ggplot_build(heatmap(mat, center = 300)))
  # luminance threshold behavior
  expect_true(rb_relative_luminance("#FFFFFF") > 0.408) # white -> dark text
  expect_true(rb_relative_luminance("#03051A") < 0.408) # dark -> light text
  # fmt parsing
  expect_identical(reaborn:::rb_format_value(112.4, "d"), "112")
  expect_identical(reaborn:::rb_format_value(0.5, ".1%"), "50.0%")
})

test_that("sns.* aliases exist for M3 functions", {
  for (fn in c(
    "sns.boxplot",
    "sns.barplot",
    "sns.stripplot",
    "sns.catplot",
    "sns.regplot",
    "sns.lmplot",
    "sns.heatmap"
  )) {
    expect_true(is.function(get(fn)), info = fn)
  }
})
