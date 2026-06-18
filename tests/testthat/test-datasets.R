# Dataset loading + seaborn-matching categorical orderings.

test_that("bundled datasets load offline", {
  pen <- load_dataset("penguins")
  expect_s3_class(pen, "data.frame")
  expect_equal(nrow(pen), 344)
  expect_true(all(c("species", "island", "bill_length_mm") %in% names(pen)))
})

test_that("categorical columns get seaborn's ordered levels", {
  tips <- load_dataset("tips")
  # seaborn stores day as an ordered category Thur < Fri < Sat < Sun
  expect_true(is.factor(tips$day))
  expect_identical(levels(tips$day), c("Thur", "Fri", "Sat", "Sun"))
  expect_identical(levels(tips$sex), c("Male", "Female"))
})

test_that("get_dataset_names returns the bundled names", {
  nm <- get_dataset_names()
  expect_true(all(c("penguins", "tips", "iris", "flights") %in% nm))
})
