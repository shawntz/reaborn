# Relational module: data assignment, estimation, and the plot builders.

test_that("rb_categorical_order matches seaborn ordering rules", {
  # factor -> levels; numeric -> sorted; character -> order of appearance
  expect_identical(
    rb_categorical_order(factor(c("b", "a"), levels = c("b", "a"))),
    c("b", "a")
  )
  expect_identical(rb_categorical_order(c(3, 1, 2)), c("1", "2", "3"))
  expect_identical(rb_categorical_order(c("z", "a", "m")), c("z", "a", "m"))
  expect_identical(
    rb_categorical_order(c("z", "a"), order = c("a", "z")),
    c("a", "z")
  )
})

test_that("rb_variable_type classifies like seaborn", {
  expect_identical(rb_variable_type(1:5), "numeric")
  expect_identical(rb_variable_type(c(1.5, 2.5)), "numeric")
  expect_identical(rb_variable_type(c("a", "b")), "categorical")
  expect_identical(rb_variable_type(factor(c("a", "b"))), "categorical")
  expect_identical(rb_variable_type(as.Date("2020-01-01")), "datetime")
})

test_that("rb_assign_variables resolves string columns and vectors", {
  df <- data.frame(a = 1:3, b = 4:6, g = c("x", "y", "x"))
  v <- rb_assign_variables(df, x = "a", y = "b", hue = "g")
  expect_identical(v$data$x, 1:3)
  expect_identical(v$names$y, "b")
  expect_identical(v$types$hue, "categorical")
  # vectors directly
  v2 <- rb_assign_variables(NULL, x = 1:3, y = 4:6)
  expect_identical(v2$data$y, 4:6)
})

test_that("estimate aggregator: deterministic error methods are exact", {
  set.seed(1)
  vals <- rnorm(50, mean = 10, sd = 2)
  # se
  a <- rb_estimate_aggregator(vals, "mean", "se")
  expect_equal(unname(a["estimate"]), mean(vals))
  half <- sd(vals) / sqrt(length(vals))
  expect_equal(unname(a["ymin"]), mean(vals) - half)
  # sd
  a2 <- rb_estimate_aggregator(vals, "mean", "sd")
  expect_equal(unname(a2["ymax"]), mean(vals) + sd(vals))
  # pi (percentile interval of data)
  a3 <- rb_estimate_aggregator(vals, "mean", list("pi", 90))
  expect_equal(
    unname(a3[c("ymin", "ymax")]),
    unname(quantile(vals, c(0.05, 0.95), names = FALSE))
  )
})

test_that("bootstrap CI brackets the estimate", {
  set.seed(1)
  vals <- rnorm(100)
  a <- rb_estimate_aggregator(
    vals,
    "mean",
    list("ci", 95),
    n_boot = 500,
    seed = 0
  )
  expect_true(a[["ymin"]] < a[["estimate"]] && a[["estimate"]] < a[["ymax"]])
  # single value -> no interval
  s <- rb_estimate_aggregator(5, "mean", list("ci", 95))
  expect_true(is.na(s[["ymin"]]))
})

test_that("scatterplot builds a composable reaborn_plot", {
  pen <- load_dataset("penguins")
  p <- scatterplot(
    data = pen,
    x = "bill_length_mm",
    y = "bill_depth_mm",
    hue = "species"
  )
  expect_s3_class(p, "reaborn_plot")
  expect_no_error(ggplot2::ggplot_build(p))
  # composes with faceting on an original column not used as an aesthetic
  expect_no_error(ggplot2::ggplot_build(p + ggplot2::facet_wrap(~island)))
})

test_that("scatterplot axis limits match seaborn (penguins)", {
  pen <- load_dataset("penguins")
  p <- scatterplot(
    data = pen,
    x = "bill_length_mm",
    y = "bill_depth_mm",
    hue = "species"
  )
  b <- ggplot2::ggplot_build(p)
  xr <- b$layout$panel_params[[1]]$x.range
  # seaborn xlim for this plot is [30.725, 60.975]
  expect_equal(xr, c(30.725, 60.975), tolerance = 1e-3)
})

test_that("lineplot aggregates and draws a band", {
  fmri <- load_dataset("fmri")
  p <- lineplot(data = fmri, x = "timepoint", y = "signal", hue = "event")
  expect_s3_class(p, "reaborn_plot")
  b <- ggplot2::ggplot_build(p)
  # a ribbon layer (band) and a line layer exist
  geoms <- vapply(b$plot$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("Ribbon", geoms)))
  expect_true(any(grepl("Line", geoms)))
})

test_that("relplot facets and returns a reaborn_plot", {
  tips <- load_dataset("tips")
  p <- relplot(
    data = tips,
    x = "total_bill",
    y = "tip",
    hue = "smoker",
    col = "time"
  )
  expect_s3_class(p, "reaborn_plot")
  expect_no_error(ggplot2::ggplot_build(p))
  pl <- relplot(
    data = load_dataset("fmri"),
    x = "timepoint",
    y = "signal",
    hue = "event",
    col = "region",
    kind = "line"
  )
  expect_no_error(ggplot2::ggplot_build(pl))
})
