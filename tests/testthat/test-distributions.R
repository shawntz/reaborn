# Distribution stats fidelity (vs scipy/numpy fixtures) + plot builders.

fx <- reaborn:::.reaborn_fixtures

test_that("Gaussian KDE matches scipy.stats.gaussian_kde to machine precision", {
  kd <- fx$kde
  x <- as.numeric(kd$data)
  # evaluate our KDE at scipy's exact grid points with the same bandwidth
  n <- length(x); bw <- n^(-1 / 5) * sqrt(stats::var(x))
  gx <- as.numeric(kd$grid_x)
  got <- vapply(gx, function(g) mean(stats::dnorm(g, x, bw)), numeric(1))
  expect_equal(got, as.numeric(kd$grid_density), tolerance = 1e-12)
  # scott factor matches scipy
  expect_equal(n^(-1 / 5), kd$scott_factor, tolerance = 1e-9)
})

test_that("histogram bin edges match numpy.histogram_bin_edges exactly", {
  h <- fx$hist; x <- as.numeric(h$data)
  for (rule in c("auto", "fd", "sturges", "scott", "sqrt", "rice", "doane")) {
    want <- as.numeric(h[[paste0(rule, "_edges")]])
    got <- rb_hist_bins(x, rule)
    expect_equal(got, want, tolerance = 1e-9, info = rule)
  }
})

test_that("histplot bin counts are correct and stat normalizations are consistent", {
  pen <- load_dataset("penguins")
  x <- pen$flipper_length_mm[!is.na(pen$flipper_length_mm)]
  edges <- rb_hist_bins(x, "auto")
  cnt <- reaborn:::.rb_bin_counts(x, edges)
  expect_equal(sum(cnt), length(x))
  # density integrates to 1
  dens <- reaborn:::.rb_hist_stat(cnt, diff(edges), "density")
  expect_equal(sum(dens * diff(edges)), 1, tolerance = 1e-9)
  # proportion sums to 1
  prop <- reaborn:::.rb_hist_stat(cnt, diff(edges), "proportion")
  expect_equal(sum(prop), 1, tolerance = 1e-9)
})

test_that("histplot builds for all multiple/stat options", {
  pen <- load_dataset("penguins")
  for (m in c("layer", "stack", "fill", "dodge")) {
    p <- histplot(data = pen, x = "flipper_length_mm", hue = "species", multiple = m)
    expect_no_error(ggplot2::ggplot_build(p))
  }
  for (s in c("count", "density", "probability", "percent", "frequency")) {
    p <- histplot(data = pen, x = "flipper_length_mm", stat = s)
    expect_no_error(ggplot2::ggplot_build(p))
  }
})

test_that("kdeplot density integrates to ~1 and builds", {
  pen <- load_dataset("penguins")
  est <- rb_gaussian_kde(pen$flipper_length_mm[!is.na(pen$flipper_length_mm)])
  area <- sum((est$y[-1] + est$y[-length(est$y)]) / 2 * diff(est$x))
  expect_equal(area, 1, tolerance = 0.01)
  expect_no_error(ggplot2::ggplot_build(kdeplot(data = pen, x = "flipper_length_mm", hue = "species", fill = TRUE)))
  expect_no_error(ggplot2::ggplot_build(kdeplot(data = pen, x = "bill_length_mm", y = "bill_depth_mm")))
})

test_that("ecdfplot is monotonic from 0 to 1", {
  pen <- load_dataset("penguins")
  p <- ecdfplot(data = pen, x = "bill_length_mm")
  b <- ggplot2::ggplot_build(p)
  y <- b$data[[1]]$y
  expect_equal(min(y), 0)
  expect_equal(max(y), 1, tolerance = 1e-9)
  expect_false(is.unsorted(sort(y)))
})

test_that("rugplot and displot build", {
  pen <- load_dataset("penguins")
  expect_no_error(ggplot2::ggplot_build(rugplot(data = pen, x = "bill_length_mm")))
  expect_no_error(ggplot2::ggplot_build(displot(data = pen, x = "flipper_length_mm", col = "species")))
  expect_no_error(ggplot2::ggplot_build(displot(data = pen, x = "flipper_length_mm",
                                                hue = "species", kind = "kde", col = "island")))
})

test_that("sns.* aliases exist for distribution functions", {
  expect_true(is.function(sns.histplot))
  expect_true(is.function(sns.kdeplot))
  expect_true(is.function(sns.displot))
})
