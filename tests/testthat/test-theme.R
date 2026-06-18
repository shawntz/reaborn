# Theme + context fidelity against ground-truth seaborn rcParams.

fx <- reaborn:::.reaborn_fixtures

test_that("plotting_context scales the base context exactly like seaborn", {
  for (ctx in c("paper", "notebook", "talk", "poster")) {
    got <- plotting_context(ctx)
    want <- fx$rc_context_raw[[ctx]]
    for (k in names(want)) {
      expect_equal(got[[k]], want[[k]], tolerance = 1e-9, info = paste(ctx, k))
    }
  }
})

test_that("font_scale multiplies only the font keys", {
  base <- plotting_context("notebook", font_scale = 1)
  scaled <- plotting_context("notebook", font_scale = 2)
  expect_equal(scaled$font.size, base$font.size * 2)
  expect_equal(scaled$axes.labelsize, base$axes.labelsize * 2)
  # non-font keys unchanged by font_scale
  expect_equal(scaled$axes.linewidth, base$axes.linewidth)
  expect_equal(scaled$lines.markersize, base$lines.markersize)
})

test_that("axes_style exposes the seaborn style fields", {
  dg <- axes_style("darkgrid")
  expect_identical(toupper(dg$facecolor), "#EAEAF2")
  expect_true(dg$grid)
  expect_false(dg$ticks)
  expect_false(axes_style("dark")$grid)
  expect_true(axes_style("ticks")$ticks)
  expect_identical(axes_style("white")$facecolor, "white")
})

test_that("theme_seaborn returns a complete ggplot2 theme", {
  thm <- theme_seaborn("darkgrid", "notebook")
  expect_s3_class(thm, "theme")
  expect_true(attr(thm, "complete"))
  # panel background fill is the seaborn darkgrid color
  expect_identical(toupper(thm$panel.background$fill), "#EAEAF2")
})

test_that("invalid style / context error", {
  expect_error(axes_style("nope"))
  expect_error(plotting_context("nope"))
})

test_that("rb_mpl_breaks reproduces matplotlib-style ticks", {
  br <- rb_mpl_breaks()(c(30.7, 61))
  expect_true(all(c(35, 40, 45, 50, 55, 60) %in% br))
  # integer-spaced, step of 5 here
  expect_equal(unique(diff(br)), 5)
})
