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
  yd <- ggplot2::ggplot_build(countplot(data = tips, y = "day", orient = "v"))$data[[1]]
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
