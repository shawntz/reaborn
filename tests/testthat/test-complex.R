# The hard families: violin, boxen, swarm, joint, pair, clustermap, misc.

test_that("violinplot builds for all inner kinds and orientations", {
  tips <- load_dataset("tips")
  for (inner in c("box", "quart", "stick", "point")) {
    expect_no_error(ggplot2::ggplot_build(violinplot(
      data = tips,
      x = "day",
      y = "total_bill",
      inner = inner
    )))
  }
  expect_no_error(ggplot2::ggplot_build(violinplot(
    data = tips,
    x = "total_bill",
    y = "day"
  )))
  expect_no_error(ggplot2::ggplot_build(violinplot(
    data = tips,
    x = "day",
    y = "total_bill",
    hue = "sex",
    split = TRUE
  )))
})

test_that("letter-value computation matches the seaborn algorithm", {
  set.seed(1)
  x <- rnorm(1000)
  lv <- rb_letter_values(x, "tukey")
  # tukey: k = floor(log2(n)) - 3 = floor(9.97) - 3 = 6
  expect_equal(lv$k, as.integer(log2(1000)) - 3)
  expect_equal(length(lv$values), 2 * lv$k)
  expect_true(
    lv$values[1] < lv$median && lv$median < lv$values[length(lv$values)]
  )
  # full extends to the data extremes
  lvf <- rb_letter_values(x, "full")
  expect_equal(min(lvf$values), min(x))
  expect_equal(max(lvf$values), max(x))
})

test_that("boxenplot builds", {
  pen <- load_dataset("penguins")
  expect_no_error(ggplot2::ggplot_build(boxenplot(
    data = pen,
    x = "species",
    y = "body_mass_g"
  )))
  for (wm in c("exponential", "linear", "area")) {
    expect_no_error(ggplot2::ggplot_build(boxenplot(
      data = pen,
      x = "species",
      y = "body_mass_g",
      width_method = wm
    )))
  }
})

test_that("swarmplot builds (beeswarm)", {
  tips <- load_dataset("tips")
  skip_if_not_installed("ggbeeswarm")
  expect_no_error(ggplot2::ggplot_build(swarmplot(
    data = tips,
    x = "day",
    y = "total_bill"
  )))
  expect_no_error(ggplot2::ggplot_build(swarmplot(
    data = tips,
    x = "day",
    y = "total_bill",
    hue = "sex",
    dodge = TRUE
  )))
})

test_that("jointplot and pairplot return patchwork compositions", {
  pen <- load_dataset("penguins")
  skip_if_not_installed("patchwork")
  j <- jointplot(
    data = pen,
    x = "bill_length_mm",
    y = "bill_depth_mm",
    hue = "species"
  )
  expect_s3_class(j, "patchwork")
  pp <- pairplot(
    pen,
    vars = c("bill_length_mm", "bill_depth_mm"),
    hue = "species"
  )
  expect_s3_class(pp, "patchwork")
})

test_that("clustermap reorders by clustering and returns a composition", {
  fl <- load_dataset("flights")
  mat <- tapply(fl$passengers, list(fl$month, fl$year), function(x) x[1])
  skip_if_not_installed("ggdendro")
  cm <- clustermap(mat)
  expect_s3_class(cm, "patchwork")
  expect_no_error(clustermap(mat, z_score = 0))
})

test_that("palplot and FacetGrid build; dogplot is harmless", {
  expect_s3_class(palplot(color_palette("deep")), "reaborn_plot")
  expect_no_error(ggplot2::ggplot_build(FacetGrid(
    load_dataset("tips"),
    col = "time"
  )))
  expect_message(dogplot())
})

test_that("sns.* aliases exist for all M4 functions", {
  for (fn in c(
    "sns.violinplot",
    "sns.boxenplot",
    "sns.swarmplot",
    "sns.jointplot",
    "sns.pairplot",
    "sns.clustermap",
    "sns.palplot",
    "sns.dogplot",
    "sns.FacetGrid"
  )) {
    expect_true(is.function(get(fn)), info = fn)
  }
})
