.onLoad <- function(libname, pkgname) {
  # Install the seaborn default look as the active global theme + color scales,
  # mirroring how `import seaborn` + set_theme() mutates matplotlib rcParams.
  # Wrapped in try() so a headless device or odd ggplot2 state can't block load.
  # (The sns.* aliases are now static exports; see R/zzz-sns-aliases.R.)
  try(set_theme(), silent = TRUE)
  invisible()
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "reaborn ", utils::packageVersion("reaborn"),
    " - seaborn, the R way. Plots are ggplots; extend them with +."
  )
}
