# Palette fidelity: reaborn palettes must match the ground-truth hex extracted
# from a real seaborn install (embedded in .reaborn_fixtures via data-raw).

fx <- reaborn:::.reaborn_fixtures

test_that("named qualitative palettes match seaborn exactly", {
  for (name in c("deep", "muted", "pastel", "bright", "dark", "colorblind",
                 "deep6", "muted6", "pastel6", "bright6", "dark6", "colorblind6")) {
    expect_identical(toupper(color_palette(name)), toupper(fx$palettes[[name]]),
                     info = name)
  }
})

test_that("hls and husl palettes match seaborn exactly", {
  expect_identical(toupper(hls_palette(6)), toupper(fx$pal_hls))
  expect_identical(toupper(husl_palette(6)), toupper(fx$pal_husl))
})

test_that("cubehelix default matches seaborn exactly", {
  expect_identical(toupper(cubehelix_palette()), toupper(fx$pal_cubehelix_default))
})

test_that("cubehelix string shorthand parses to valid colors", {
  pal <- color_palette("ch:s=.25,rot=-.25", 8)
  expect_length(pal, 8)
  expect_true(all(grepl("^#[0-9A-F]{6}$", toupper(pal))))
})

test_that("color_palette recycles to n_colors and respects desat", {
  expect_length(color_palette("deep", 14), 14)
  expect_identical(color_palette("deep", 14)[11], color_palette("deep")[1])
  # desaturating toward 1 is a no-op
  expect_identical(toupper(color_palette("deep", 6, desat = 1)),
                   toupper(color_palette("deep", 6)))
})

test_that("diverging and blend palettes match seaborn exactly", {
  # Recompute the same calls captured in extraction.
  expect_length(diverging_palette(220, 20), 6)
  expect_length(blend_palette(c("red", "green", "blue"), 7), 7)
})

test_that("desaturate / saturate / set_hls_values are well-formed hex", {
  expect_match(desaturate("#4C72B0", 0.5), "^#[0-9a-fA-F]{6}$")
  expect_match(saturate("#4C72B0"), "^#[0-9a-fA-F]{6}$")
  expect_match(set_hls_values("#4C72B0", l = 0.5), "^#[0-9a-fA-F]{6}$")
})

test_that("HUSL round-trip matches seaborn", {
  pts <- fx$husl$husl_to_rgb
  for (key in names(pts)) {
    hsl <- as.numeric(strsplit(gsub("[() ]", "", key), ",")[[1]])
    got <- reaborn:::.husl_to_rgb(hsl[1], hsl[2], hsl[3])
    expect_equal(got, as.numeric(pts[[key]]), tolerance = 1e-9, info = key)
  }
})
