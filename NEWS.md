# reaborn v1.0.1

* Patch release fixing a critical bug in how `NA` values were handled.

## What's Changed

* Update README.md with CRAN badges by @shawntz in #48
* chore(figures): refresh comparison figures by @github-actions[bot] in #46
* chore(figures): refresh hero collage by @github-actions[bot] in #47
* fix(kdeplot): honor cmap and correct contour levels in filled bivariate KDE by @shawntz in #49
* feat(histplot): add bivariate 2-D histogram (count heatmap) mode by @shawntz in #50
* docs: add runnable example plots to every plot reference page by @shawntz in #51
* chore(figures): refresh hero collage by @github-actions[bot] in #52
* chore(figures): refresh comparison figures by @github-actions[bot] in #53
* chore: bump version to 1.0.0.9000 by @shawntz in #54
* Gate bivariate histogram colorbar on legend = FALSE by @shawntz in #56
* chore(figures): refresh comparison figures by @github-actions[bot] in #55
* chore(figures): refresh hero collage by @github-actions[bot] in #57
* Clarify histplot bivariate docs for hue and cbar_kws by @shawntz in #58
* chore(figures): refresh hero collage by @github-actions[bot] in #59
* chore(figures): refresh comparison figures by @github-actions[bot] in #60
* fix(docs): close histplot.Rd \details block to fix R CMD check by @shawntz in #61
* fix(datasets): read empty CSV fields as NA to match pandas/seaborn by @shawntz in #62
* fix(countplot): draw horizontal bars when the category is assigned to y by @shawntz in #63
* chore(figures): refresh hero collage by @github-actions[bot] in #64
* chore(figures): refresh comparison figures by @github-actions[bot] in #65
* fix(displot): drop NA facet levels to prevent empty-group KDE error by @shawntz in #66
* chore(figures): refresh hero collage by @github-actions[bot] in #67
* chore(figures): refresh comparison figures by @github-actions[bot] in #68

**Full Changelog**: https://github.com/shawntz/reaborn/compare/v1.0.0...v1.0.1

# reaborn v1.0.0

* Initial release.

## What's Changed

* v0.0.0.9000 by @shawntz in #1
* Add air format check CI workflow and config by @shawntz in #12
* Add air format suggest CI workflow by @shawntz in #8
* Add main branch version badge workflow by @shawntz in #9
* Remove look-alike sentence from pkgdown homepage figcaption by @shawntz in #2
* fix(barplot): match seaborn CI error-bar line thickness by @shawntz in #3
* Fix grammar on 'seaborn defaults, on import' card by @shawntz in #4
* Rework landing-page fidelity card for accuracy by @shawntz in #5
* Match seaborn's colorbar format in heatmap() by @shawntz in #7
* Adopt eyeris multi-platform build/check workflow by @shawntz in #10
* Match seaborn's KDE/hue legend styling by @shawntz in #11
* ci: regenerate hero collage on merge to main by @shawntz in #13
* Add spellcheck CI workflow for R package docs by @shawntz in #14
* Match seaborn's legend background color and inside placement by @shawntz in #6
* style: apply air formatting across the codebase by @shawntz in #15
* chore(figures): refresh hero collage by @github-actions[bot] in #17
* docs: add status badges to README and pkgdown home page by @shawntz in #18
* chore: add spelling WORDLIST to pass spellcheck by @shawntz in #16
* chore(figures): refresh hero collage by @github-actions[bot] in #19
* chore: add Lifecycle and pkgdown to WORDLIST by @shawntz in #21
* fix(ci): stop hero-collage workflow from looping refresh PRs by @shawntz in #22
* chore: rename pkgdown badge title to "website" by @shawntz in #23
* chore: add "dev" to spellcheck wordlist by @shawntz in #25
* chore(badge): relabel "main" version badge as "dev version" by @shawntz in #24
* chore(figures): refresh hero collage by @github-actions[bot] in #20
* ci(figures): auto-regenerate compare-*.png on code changes by @shawntz in #26
* chore(figures): refresh comparison figures by @github-actions[bot] in #27
* docs(comparison): remove fidelity paragraph from vs Seaborn page by @shawntz in #28
* docs(comparison): drop palette-system bullet from vs-seaborn page by @shawntz in #29
* docs(comparison): remove statistics bullet from vs seaborn page by @shawntz in #30
* docs(comparison): remove "honest framing" sentence from vs seaborn page by @shawntz in #31
* docs(comparison): reword "skip the boilerplate" bullet by @shawntz in #32
* docs(comparison): remove feature comparison table from vs Seaborn page by @shawntz in #34
* docs: add NEWS.md changelog for pkgdown site by @shawntz in #33
* feat(logo): hex sticker logo + right-aligned README logo by @shawntz in #35
* Update README.md by @shawntz in #36
* Set new hex sticker logo as website favicon by @shawntz in #37
* feat(website): show hex sticker logo in navbar on every page by @shawntz in #38
* fix(website): show navbar hex logo on all pages (root-relative paths) by @shawntz in #39
* chore: ignore .air.toml in package build by @shawntz in #40
* fix(website): use absolute URL for navbar logo to unblock pkgdown build by @shawntz in #41

## New Contributors

* @shawntz made their first contribution in #1
* @github-actions[bot] made their first contribution in #17

**Full Changelog**: https://github.com/shawntz/reaborn/commits/v1.0.0
