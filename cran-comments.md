## CRAN Submission

This is a resubmission of the initial submission for the package, reaborn, an R port of Python’s seaborn, built on ggplot2. It mirrors seaborn’s function API exactly and renders visually indistinguishable plots — and because every result is a real ggplot, you can keep extending it with the grammar of graphics.

This 1.0.1 patch release fixes a critical bug in how missing (`NA`) values were handled.

## Notes

This resubmission fixes the following comments:

> Possibly misspelled words in DESCRIPTION:
>     reaborn (8:59, 11:19)
>
> Please single quote software names in both Title and Description fields
> of the DESCRIPTION file, this inclused 'reaborn' and 'R' (which many
> people forget to quote).
>
> Please fix and resubmit.

All checks (`R CMD check`, `devtools::check(remote = TRUE)`, GitHub Actions CI) pass on macOS, Windows, and Ubuntu.

Thank you for your time and consideration.

## R CMD check results (reaborn v1.0.0)

Duration: 44.3s

❯ checking CRAN incoming feasibility ... [2s/14s] NOTE
  Maintainer: ‘Shawn Schwartz <shawn.t.schwartz@gmail.com>’
  
  New submission

0 errors ✔ | 0 warnings ✔ | 1 note ✖

## Downstream dependencies

No strong reverse dependencies to be checked.
