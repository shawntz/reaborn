# Changelog

## reaborn v1.0.1

CRAN release: 2026-07-03

- Patch release fixing a critical bug in how `NA` values were handled.

### What’s Changed

- Update README.md with CRAN badges by
  [@shawntz](https://github.com/shawntz) in
  [\#48](https://github.com/shawntz/reaborn/issues/48)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#46](https://github.com/shawntz/reaborn/issues/46)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#47](https://github.com/shawntz/reaborn/issues/47)
- fix(kdeplot): honor cmap and correct contour levels in filled
  bivariate KDE by [@shawntz](https://github.com/shawntz) in
  [\#49](https://github.com/shawntz/reaborn/issues/49)
- feat(histplot): add bivariate 2-D histogram (count heatmap) mode by
  [@shawntz](https://github.com/shawntz) in
  [\#50](https://github.com/shawntz/reaborn/issues/50)
- docs: add runnable example plots to every plot reference page by
  [@shawntz](https://github.com/shawntz) in
  [\#51](https://github.com/shawntz/reaborn/issues/51)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#52](https://github.com/shawntz/reaborn/issues/52)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#53](https://github.com/shawntz/reaborn/issues/53)
- chore: bump version to 1.0.0.9000 by
  [@shawntz](https://github.com/shawntz) in
  [\#54](https://github.com/shawntz/reaborn/issues/54)
- Gate bivariate histogram colorbar on legend = FALSE by
  [@shawntz](https://github.com/shawntz) in
  [\#56](https://github.com/shawntz/reaborn/issues/56)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#55](https://github.com/shawntz/reaborn/issues/55)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#57](https://github.com/shawntz/reaborn/issues/57)
- Clarify histplot bivariate docs for hue and cbar_kws by
  [@shawntz](https://github.com/shawntz) in
  [\#58](https://github.com/shawntz/reaborn/issues/58)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#59](https://github.com/shawntz/reaborn/issues/59)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#60](https://github.com/shawntz/reaborn/issues/60)
- fix(docs): close histplot.Rd block to fix R CMD check by
  [@shawntz](https://github.com/shawntz) in
  [\#61](https://github.com/shawntz/reaborn/issues/61)
- fix(datasets): read empty CSV fields as NA to match pandas/seaborn by
  [@shawntz](https://github.com/shawntz) in
  [\#62](https://github.com/shawntz/reaborn/issues/62)
- fix(countplot): draw horizontal bars when the category is assigned to
  y by [@shawntz](https://github.com/shawntz) in
  [\#63](https://github.com/shawntz/reaborn/issues/63)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#64](https://github.com/shawntz/reaborn/issues/64)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#65](https://github.com/shawntz/reaborn/issues/65)
- fix(displot): drop NA facet levels to prevent empty-group KDE error by
  [@shawntz](https://github.com/shawntz) in
  [\#66](https://github.com/shawntz/reaborn/issues/66)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#67](https://github.com/shawntz/reaborn/issues/67)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#68](https://github.com/shawntz/reaborn/issues/68)

**Full Changelog**:
<https://github.com/shawntz/reaborn/compare/v1.0.0>…v1.0.1

## reaborn v1.0.0

CRAN release: 2026-06-30

- Initial release.

### What’s Changed

- v0.0.0.9000 by [@shawntz](https://github.com/shawntz) in
  [\#1](https://github.com/shawntz/reaborn/issues/1)
- Add air format check CI workflow and config by
  [@shawntz](https://github.com/shawntz) in
  [\#12](https://github.com/shawntz/reaborn/issues/12)
- Add air format suggest CI workflow by
  [@shawntz](https://github.com/shawntz) in
  [\#8](https://github.com/shawntz/reaborn/issues/8)
- Add main branch version badge workflow by
  [@shawntz](https://github.com/shawntz) in
  [\#9](https://github.com/shawntz/reaborn/issues/9)
- Remove look-alike sentence from pkgdown homepage figcaption by
  [@shawntz](https://github.com/shawntz) in
  [\#2](https://github.com/shawntz/reaborn/issues/2)
- fix(barplot): match seaborn CI error-bar line thickness by
  [@shawntz](https://github.com/shawntz) in
  [\#3](https://github.com/shawntz/reaborn/issues/3)
- Fix grammar on ‘seaborn defaults, on import’ card by
  [@shawntz](https://github.com/shawntz) in
  [\#4](https://github.com/shawntz/reaborn/issues/4)
- Rework landing-page fidelity card for accuracy by
  [@shawntz](https://github.com/shawntz) in
  [\#5](https://github.com/shawntz/reaborn/issues/5)
- Match seaborn’s colorbar format in heatmap() by
  [@shawntz](https://github.com/shawntz) in
  [\#7](https://github.com/shawntz/reaborn/issues/7)
- Adopt eyeris multi-platform build/check workflow by
  [@shawntz](https://github.com/shawntz) in
  [\#10](https://github.com/shawntz/reaborn/issues/10)
- Match seaborn’s KDE/hue legend styling by
  [@shawntz](https://github.com/shawntz) in
  [\#11](https://github.com/shawntz/reaborn/issues/11)
- ci: regenerate hero collage on merge to main by
  [@shawntz](https://github.com/shawntz) in
  [\#13](https://github.com/shawntz/reaborn/issues/13)
- Add spellcheck CI workflow for R package docs by
  [@shawntz](https://github.com/shawntz) in
  [\#14](https://github.com/shawntz/reaborn/issues/14)
- Match seaborn’s legend background color and inside placement by
  [@shawntz](https://github.com/shawntz) in
  [\#6](https://github.com/shawntz/reaborn/issues/6)
- style: apply air formatting across the codebase by
  [@shawntz](https://github.com/shawntz) in
  [\#15](https://github.com/shawntz/reaborn/issues/15)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#17](https://github.com/shawntz/reaborn/issues/17)
- docs: add status badges to README and pkgdown home page by
  [@shawntz](https://github.com/shawntz) in
  [\#18](https://github.com/shawntz/reaborn/issues/18)
- chore: add spelling WORDLIST to pass spellcheck by
  [@shawntz](https://github.com/shawntz) in
  [\#16](https://github.com/shawntz/reaborn/issues/16)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#19](https://github.com/shawntz/reaborn/issues/19)
- chore: add Lifecycle and pkgdown to WORDLIST by
  [@shawntz](https://github.com/shawntz) in
  [\#21](https://github.com/shawntz/reaborn/issues/21)
- fix(ci): stop hero-collage workflow from looping refresh PRs by
  [@shawntz](https://github.com/shawntz) in
  [\#22](https://github.com/shawntz/reaborn/issues/22)
- chore: rename pkgdown badge title to “website” by
  [@shawntz](https://github.com/shawntz) in
  [\#23](https://github.com/shawntz/reaborn/issues/23)
- chore: add “dev” to spellcheck wordlist by
  [@shawntz](https://github.com/shawntz) in
  [\#25](https://github.com/shawntz/reaborn/issues/25)
- chore(badge): relabel “main” version badge as “dev version” by
  [@shawntz](https://github.com/shawntz) in
  [\#24](https://github.com/shawntz/reaborn/issues/24)
- chore(figures): refresh hero collage by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#20](https://github.com/shawntz/reaborn/issues/20)
- ci(figures): auto-regenerate compare-\*.png on code changes by
  [@shawntz](https://github.com/shawntz) in
  [\#26](https://github.com/shawntz/reaborn/issues/26)
- chore(figures): refresh comparison figures by
  [@github-actions](https://github.com/github-actions)\[bot\] in
  [\#27](https://github.com/shawntz/reaborn/issues/27)
- docs(comparison): remove fidelity paragraph from vs Seaborn page by
  [@shawntz](https://github.com/shawntz) in
  [\#28](https://github.com/shawntz/reaborn/issues/28)
- docs(comparison): drop palette-system bullet from vs-seaborn page by
  [@shawntz](https://github.com/shawntz) in
  [\#29](https://github.com/shawntz/reaborn/issues/29)
- docs(comparison): remove statistics bullet from vs seaborn page by
  [@shawntz](https://github.com/shawntz) in
  [\#30](https://github.com/shawntz/reaborn/issues/30)
- docs(comparison): remove “honest framing” sentence from vs seaborn
  page by [@shawntz](https://github.com/shawntz) in
  [\#31](https://github.com/shawntz/reaborn/issues/31)
- docs(comparison): reword “skip the boilerplate” bullet by
  [@shawntz](https://github.com/shawntz) in
  [\#32](https://github.com/shawntz/reaborn/issues/32)
- docs(comparison): remove feature comparison table from vs Seaborn page
  by [@shawntz](https://github.com/shawntz) in
  [\#34](https://github.com/shawntz/reaborn/issues/34)
- docs: add NEWS.md changelog for pkgdown site by
  [@shawntz](https://github.com/shawntz) in
  [\#33](https://github.com/shawntz/reaborn/issues/33)
- feat(logo): hex sticker logo + right-aligned README logo by
  [@shawntz](https://github.com/shawntz) in
  [\#35](https://github.com/shawntz/reaborn/issues/35)
- Update README.md by [@shawntz](https://github.com/shawntz) in
  [\#36](https://github.com/shawntz/reaborn/issues/36)
- Set new hex sticker logo as website favicon by
  [@shawntz](https://github.com/shawntz) in
  [\#37](https://github.com/shawntz/reaborn/issues/37)
- feat(website): show hex sticker logo in navbar on every page by
  [@shawntz](https://github.com/shawntz) in
  [\#38](https://github.com/shawntz/reaborn/issues/38)
- fix(website): show navbar hex logo on all pages (root-relative paths)
  by [@shawntz](https://github.com/shawntz) in
  [\#39](https://github.com/shawntz/reaborn/issues/39)
- chore: ignore .air.toml in package build by
  [@shawntz](https://github.com/shawntz) in
  [\#40](https://github.com/shawntz/reaborn/issues/40)
- fix(website): use absolute URL for navbar logo to unblock pkgdown
  build by [@shawntz](https://github.com/shawntz) in
  [\#41](https://github.com/shawntz/reaborn/issues/41)

### New Contributors

- @shawntz made their first contribution in
  [\#1](https://github.com/shawntz/reaborn/issues/1)
- @github-actions\[bot\] made their first contribution in
  [\#17](https://github.com/shawntz/reaborn/issues/17)

**Full Changelog**: <https://github.com/shawntz/reaborn/commits/v1.0.0>
