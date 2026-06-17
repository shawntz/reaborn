# Copy-paste compatibility layer: Python literals, sns.* aliases, composability.

test_that("Python literal bindings resolve to R equivalents", {
  expect_identical(True, TRUE)
  expect_identical(False, FALSE)
  expect_null(None)
})

test_that("sns.* dotted aliases exist and point at the same functions", {
  expect_true(is.function(sns.color_palette))
  expect_identical(sns.color_palette("deep"), color_palette("deep"))
  expect_true(is.function(sns.set_theme))
  expect_true(is.function(sns.despine))
})

test_that("reaborn plots are ggplots and compose with +", {
  set_theme()
  p <- reaborn_plot(
    ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  )
  expect_s3_class(p, "reaborn_plot")
  expect_s3_class(p, "ggplot")
  # adding a ggplot component keeps it a reaborn_plot
  p2 <- p + ggplot2::theme(legend.position = "top")
  expect_s3_class(p2, "reaborn_plot")
  p3 <- p + ggplot2::facet_wrap(~cyl)
  expect_s3_class(p3, "ggplot")
})

test_that("despine and move_legend return addable theme objects", {
  expect_s3_class(despine(), "theme")
  expect_s3_class(move_legend(loc = "upper right"), "theme")
})
